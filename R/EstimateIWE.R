EstimateIWE <- function(y, treatment, group, controls, fe.other = NULL, data, subset = NULL,
  cluster.var = NULL, is.robust = TRUE){
  subset.check <- try(class(subset), silent = TRUE)
  if(class(subset.check) == "try-error"){
    subset <- substitute(subset)
    data <- data[eval(subset, data), ]
  } else {
    subset <- NULL
  }

  ## Check inputs
  CheckSweInputs(y, treatment, group, controls, fe.other, data, subset,
    cluster.var, is.robust)
  data <- droplevels(data)

  ## Coerce if necessary
  if(!class(data[[group]]) %in% c("character", "factor")){
    data[[group]] <- as.character(data[[group]])
  }

  covariates <- MakeCovariatesLM(group, treatment, controls, fe.other)

  formula.base <- paste(y, "~", treatment, covariates$controls, "+", covariates$fe)
  formula.int  <- paste(y, "~", treatment, "/", group, covariates$controls, "+",
    covariates$fe)
  formula.base <- formula(formula.base)
  formula.int  <- formula(formula.int)

  ## Base model
  reg.fe.c <- call("lm", formula = formula.base, data = data)
  reg.fe <- eval(reg.fe.c)
  reg.fe$call <- match.call() # Change call printed from lm version to IWE

  N <- nrow(reg.fe$model)
  M <- length(unique(data[[group]]))

  ## Calculate sample weights
  f.table <- table(data[names(reg.fe$fitted.values), group])
  if(any(f.table < 2)){
    stop("All groups must contain more than one observation for identification")
  }
  f.weights <- prop.table(f.table)

  ## Base variance-covariance matrix
  if(!is.null(cluster.var)){
    cluster.obs <- data[names(reg.fe$residuals), cluster.var]
    reg.fe$clustervcv <- ClusterVCV(reg.fe, cluster.obs)
  }
  if(is.robust){
    reg.fe$robustvcv <- vcovHC(reg.fe)
  }

  ## Interacted model
  reg.int.c <- call("lm", formula = formula.int, data = data)
  reg.int <- eval(reg.int.c)
  reg.int$call <- match.call() # Change call printed from lm version to IWE

  ## Interacted variance-covariance matrix
  if(!is.null(cluster.var)){
    reg.int$clustervcv <- ClusterVCV(reg.int, data[names(reg.int$residuals), cluster.var])
  }
  if(is.robust){
    reg.int$robustvcv <- vcovHC(reg.int)
  }

  ## Results
  results <- list(y = y, group = group, treatment = treatment, controls = controls,
    fe.other = fe.other,  cluster.var = cluster.var, subset = subset,
    is.robust = is.robust, N = N, M = M,
    formula.fe = formula.base, formula.int = formula.int, f.weights = f.weights,
    reg.fe = reg.fe, reg.int = reg.int)
  if(!is.null(cluster.var)){
    results$cluster.obs <- cluster.obs
  }
  class(results) <- "iwe"
  return(results)
}