% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/hdlandmark.R
\name{hdlandmark}
\alias{hdlandmark}
\title{Compute individual dynamic prediction of clinical endpoint using large dimensional longitudinal biomarker history}
\usage{
hdlandmark(data, data.pred = NULL, markers, tLMs, tHors, subject, time,
  time.event, event, long.method = c("combine", "GLMM", "MFPC"),
  lmm.package = c("lme4", "lcmm"), surv.covar = c("baseline", "LOtLM"),
  cox.submodels = c("autoVar", "allVar"), coxnet.submodels = c("opt",
  "lasso", "ridge"), spls.submodels = c("opt", "nosparse", "maxsparse"),
  rsf.submodels = c("opt", "noVS", "default"), rsf.split = c("logrank",
  "bs.gradient"), kfolds = 10, seed = 1234, scaling = FALSE,
  SL.weights = NULL)
}
\arguments{
\item{data}{data.frame object containing longitudinal and survival data}

\item{data.pred}{(optional) data.frame object for predictions. If missing, \code{data.pred} is made using \code{kfolds} cross-validation}

\item{markers}{list containing the modeling of repeated measures for each marker}

\item{tLMs}{numeric vector of landmark times}

\item{tHors}{numeric vector of horizon times}

\item{subject}{variable name in data (and \code{data.pred}) that identifies the different subjects}

\item{time}{variable name in data (and \code{data.pred}) which contains time measurements}

\item{time.event}{variable name in data (and \code{data.pred}) which contains time-to-event}

\item{event}{variable name in data (and \code{data.pred}) which contains time-to-event}

\item{long.method}{character that specifies how to model the longitudinal data. Choices are \code{GLMM} for generalized mixed model \insertCite{laird_random-effects_1982}{hdlandmark},
\code{MFPC} for multivariate functional principal components \insertCite{yao_functional_2005}{hdlandmark} (works only on continuous markers) or \code{combine} for both.}

\item{lmm.package}{package to model longitudinal data, either \code{lme4} or \code{lcmm}}

\item{surv.covar}{covariates measure at \code{baseline} or last observation before landmark time \code{LOtLM}}

\item{cox.submodels}{a character vector containing Cox submodels \insertCite{cox_regression_1972}{hdlandmark}. \code{autoVar} for Cox with backward variable selection. \code{allVar} for Cox with all variables}

\item{coxnet.submodels}{a character vector containing penalized Cox submodels \insertCite{simon_regularization_2011}{hdlandmark}. \code{opt} for tuning the elastic net parameter penalty, \code{lasso} for lasso penalty and \code{ridge} for ridge penalty.}

\item{spls.submodels}{a character vector containing Deviance residuals sparse-Partial Least Square sub-methods \insertCite{bastien_deviance_2015}{hdlandmark}. \code{opt} for tuning sparcity parameter \eqn{\eta}, \code{nosparse} for \eqn{\eta = 0} and \code{maxsparse} for \eqn{\eta = 0.9} \insertCite{@see also @chun_sparse_2010}{hdlandmark}}

\item{rsf.submodels}{a character vector containing random survival forests sub-methods \insertCite{ishwaran_random_2008}{hdlandmark}.}

\item{rsf.split}{a character vector containing the split criterion for random survival forests sub-methods. \code{logrank} for log-rank splitting or \code{bs.gradient} for gradient-based brier score splitting.}

\item{kfolds}{number of fold in cross-validation}

\item{seed}{(optional) seed number}

\item{scaling}{boolean to scale summaries (default is \code{FALSE})}

\item{SL.weights}{(optional) allow to compute individual probabilities from a superlearner using numeric vector of weights for each sub-methods}
}
\value{
\item{tLMs}{landmark time(s)}
\item{tHors}{horizon time(s)}
\item{models}{a list for each landmark time(s):}
\itemize{
 \item \code{data.surv} input data in survival methods for training (only available on the last fold)
 \item \code{data.surv.pred} input data in survival methods for predicting (only available on the last fold)
 \item \code{model.surv} output object for the selected survival predictive methods (only available on the last fold)
 \item \code{pred.surv} for each horizon time(s), containing the individual probabilities for the selected survival predictive methods
 \item \code{AUC} list of horizon time(s) containing AUC for each fold for the selected survival predictive methods
 \item \code{BS} list of horizon time(s) containing BS for each fold for the selected survival predictive methods
}
\item{long.method}{method(s) used to modeling the biomarkers}
\item{surv.methods}{method(s) used to compute the individual survival prediction}
\item{models.name}{name of survival prediction methods}
\item{kfolds}{number of folds}
}
\description{
hdlandmark provides individual survival probabilities using covariates and summaries build
on longitudinal data from biomarkers collected over the time.
For each biomarker, an ensemble of predictive summaries are computed at the user-specified landmark time \code{tLM}.
For instance, we use random-effects, level, slope and cumulative level. Then, these summaries and covariates are used as input in several survival prediction methods including: Cox model (his extension with penalty), sparse-Partial Least Square for survival data and random survival forests
For each survival prediction method, we provide the individual prediction on horizon time \code{tHor}.
}
\examples{

library(splines)
library(rstpm2)

data(pbc2)

# Formula for the modeling of the biomarkers using splines
marker <-
    list(serBilir = list(model = list(fixed = serBilir ~ ns(year, knots = c(0.5, 2.0), Boundary.knots = c(0,4)),
                                  random = ~ ns(year, knots = c(0.5, 2.0), Boundary.knots = c(0,4)),
                                  subject = "id"),
                         deriv = list(fixed = ~ -1 + nsxD(year, knots = c(0.5, 2.0), Boundary.knots = c(0,4)),
                                  indFixed = c(2,3,4),
                                  random = ~ -1 + nsxD(year, knots = c(0.5, 2.0), Boundary.knots = c(0,4)),
                                  indRandom = c(2,3,4))),
    serChol = list(model = list(fixed = serChol ~ ns(year, knots = c(0.5, 2.0), Boundary.knots = c(0,4)),
                                 random = ~ ns(year, knots = c(0.5, 2.0), Boundary.knots = c(0,4)),
                                 subject = "id"),
                    deriv = list(fixed = ~ -1 + nsxD(year, knots = c(0.5, 2.0), Boundary.knots = c(0,4)),
                                 indFixed = c(2,3,4),
                                 random = ~ -1 + nsxD(year, knots = c(0.5, 2.0), Boundary.knots = c(0,4)),
                                 indRandom = c(2,3,4))),
    albumin = list(model = list(fixed = albumin ~ ns(year, knots = c(0.5, 2.0), Boundary.knots = c(0,4)),
                                random = ~ ns(year, knots = c(0.5, 2.0), Boundary.knots = c(0,4)),
                                subject = "id"),
                   deriv = list(fixed = ~ -1 + nsxD(year, knots = c(0.5, 2.0), Boundary.knots = c(0,4)),
                                indFixed = c(2,3,4),
                                random = ~ -1 + nsxD(year, knots = c(0.5, 2.0), Boundary.knots = c(0,4)),
                                indRandom = c(2,3,4))),
    alkaline = list(model = list(fixed = alkaline ~ ns(year, knots = c(0.5, 2.0), Boundary.knots = c(0,4)),
                                 random = ~ ns(year, knots = c(0.5, 2.0), Boundary.knots = c(0,4)),
                                 subject = "id"),
                    deriv = list(fixed = ~ -1 + nsxD(year, knots = c(0.5, 2.0), Boundary.knots = c(0,4)),
                                 indFixed = c(2,3,4),
                                 random = ~ -1 + nsxD(year, knots = c(0.5, 2.0), Boundary.knots = c(0,4)),
                                 indRandom = c(2,3,4))),
    SGOT = list(model = list(fixed = SGOT ~ ns(year, knots = c(0.5, 2.0), Boundary.knots = c(0,4)),
                             random = ~ ns(year, knots = c(0.5, 2.0), Boundary.knots = c(0,4)),
                             subject = "id"),
                deriv = list(fixed = ~ -1 + nsxD(year, knots = c(0.5, 2.0), Boundary.knots = c(0,4)),
                             indFixed = c(2,3,4),
                             random = ~ -1 + nsxD(year, knots = c(0.5, 2.0), Boundary.knots = c(0,4)),
                             indRandom = c(2,3,4))),
    platelets = list(model = list(fixed = platelets ~ ns(year, knots = c(0.5, 2.0), Boundary.knots = c(0,4)),
                                  random = ~ ns(year, knots = c(0.5, 2.0), Boundary.knots = c(0,4)),
                                  subject = "id"),
                     deriv = list(fixed = ~ -1 + nsxD(year, knots = c(0.5, 2.0), Boundary.knots = c(0,4)),
                                  indFixed = c(2,3,4),
                                  random = ~ -1 + nsxD(year, knots = c(0.5, 2.0), Boundary.knots = c(0,4)),
                                  indRandom = c(2,3,4))),
    prothrombin = list(model = list(fixed = prothrombin ~ ns(year, knots = c(0.5, 2.0), Boundary.knots = c(0,4)),
                                    random = ~ ns(year, knots = c(0.5, 2.0), Boundary.knots = c(0,4)),
                                    subject = "id"),
                       deriv = list(fixed = ~ -1 + nsxD(year, knots = c(0.5, 2.0), Boundary.knots = c(0,4)),
                                    indFixed = c(2,3,4),
                                    random = ~ -1 + nsxD(year, knots = c(0.5, 2.0), Boundary.knots = c(0,4)),
                                    indRandom = c(2,3,4))),
    ascites = list(model = ascites ~ year + (1 + year|id),
                   deriv = list(fixed = ~ 1,
                                indFixed = 2,
                                random = ~ 1,
                                indRandom = 2)),
    hepatomegaly = list(model = hepatomegaly ~ ns(year, knots = c(1.0), Boundary.knots = c(0,4)) +
                        (1 + ns(year, knots = c(1.0), Boundary.knots = c(0,4))||id),
                        deriv = list(fixed = ~ -1 + nsxD(year, knots = c(1.0), Boundary.knots = c(0,4)),
                                     indFixed = c(2,3),
                                     random = ~ -1 + nsxD(year, knots = c(1.0), Boundary.knots = c(0,4)),
                                     indRandom = c(2,3))),
    spiders = list(model = spiders ~ ns(year, knots = c(1.0), Boundary.knots = c(0,4)) +
                    (1 + ns(year, knots = c(1.0), Boundary.knots = c(0,4))||id),
                    deriv = list(fixed = ~ -1 + nsxD(year, knots = c(1.0), Boundary.knots = c(0,4)),
                                 indFixed = c(2,3),
                                 random = ~ -1 + nsxD(year, knots = c(1.0), Boundary.knots = c(0,4)),
                                 indRandom = c(2,3))),
    edema2 = list(model = edema2 ~ year + (1 + year|id),
                  deriv = list(fixed = ~ 1,
                               indFixed = 2,
                               random = ~ 1,
                               indRandom = 2))
)

# compute hdlandmark methodology
hdlandmark.res <- hdlandmark(data = pbc2, data.pred = pbc2, markers = marker,
                             tLMs = 4, tHors = 3,
                             subject = "id", time = "year", time.event = "years", event = "status2",
                             long.method = "GLMM", lmm.package = "lcmm", surv.covar = "baseline",
                             cox.submodels = "allVar",
                             coxnet.submodels = "lasso",
                             spls.submodels = "nosparse",
                             rsf.submodels = "default",
                             rsf.split = c("logrank"),
                             kfolds = 10)

# get individual predictions for each method
hdlandmark.res$models[[`4`]]$pred.surv$`3`


}
\references{
\insertAllCited{}
}
\author{
Anthony Devaux (\email{anthony.devaux@u-bordeaux.fr}) (maintener), Robin Genuer and Cécile Proust-Lima
}
