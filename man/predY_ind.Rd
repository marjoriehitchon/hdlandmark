% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/predY_ind.R
\name{predY_ind}
\alias{predY_ind}
\title{Function to predict the value of longitudinal outcome for a specific time}
\usage{
predY_ind(predRE, data, time, tLM, threshold = NULL)
}
\arguments{
\item{predRE}{A list object from \code{predRE} function}

\item{data}{A dataframe where each row containing some predictive variables for a specific subject}
}
\value{
A matrix containing the prediction value of the longitudinal outcome for each subject
}
\description{
Function to predict the value of longitudinal outcome for a specific time
}
\examples{

}
