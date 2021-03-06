\name{ScoreTest}
\alias{ScoreTest}
\alias{WaldTestIWE}
\alias{print.chisq.test}
\title{Test for heterogeneous treatment effects}
\description{Perform score or Wald tests for heterogeneous treatment
	effects as described in Gibbons et al. (2018). The Wald test is
	implemented only for the IWE estimator and the score test only for the
  RWE estimator.}
\usage{
ScoreTest(model)
WaldTestIWE(model)
\method{print}{chisq.test}(x, ...)
}
\arguments{
  \item{model}{A model of class 'iwe' or 'rwe' (for the score test) or of class 'iwe' only (for the Wald test)}
  \item{x}{Results of the score, Wald, or specification tests}
  \item{...}{Not currently used}
}
\value{List of class 'chisq.test'
  \item{stat}{Chi-squared test statistic}
  \item{df}{Degrees-of-freedom for the Chi-squared test}
}
\references{Gibbons, Charles E., Juan Carlos Suarez Serrato, and Michael
	B. Urbancic. 2018. "Broken or Fixed Effects?" \emph{Journal of
		Econometric Methods}.}

\examples{
data(CensusData, package = "bfe")

wage.iwe <- EstimateIWE("lnww", "educ", "age_dum", c("state", "year", "birthpl"),
  NULL, CensusData, NULL, "st.year")

wage.rwe <- EstimateRWE("lnww", "educ", "age_dum", c("state", "year", "birthpl"),
  NULL, CensusData, NULL, "st.year")

wage.wald  <- WaldTestIWE(wage.iwe)
wage.rwe.score <- ScoreTest(wage.rwe)
}
\keyword{regression}
