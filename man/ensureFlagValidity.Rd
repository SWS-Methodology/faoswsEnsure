% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ensureFlagValidity.R
\name{ensureFlagValidity}
\alias{ensureFlagValidity}
\title{This function checks whether the flags in the data are valid according to
the flagValidTable.}
\usage{
ensureFlagValidity(data, flagObservationVar = "flagObservationStatus",
  flagMethodVar = "flagMethod", returnData = TRUE, normalised = TRUE,
  denormalisedKey = "measuredElement", flagTable = flagValidTable,
  getInvalidData = FALSE, removeInvalid = TRUE)
}
\arguments{
\item{data}{The data to be checked}

\item{flagObservationVar}{The column name corresponding to the observation
status flag.}

\item{flagMethodVar}{The column name corresponding to the method flag.}

\item{returnData}{logical, whether the data should be returned}

\item{normalised}{logical, whether the data is normalised}

\item{denormalisedKey}{optional, only required if the input data is not
normalised.It is the name of the key that denormalises the data.}

\item{flagTable}{The table containing valid/invalid flag combination. See
the dataset flagValidTable in \pkg{faoswsFlag}}

\item{getInvalidData}{logical, this will skip the test and extract the data
that is invalid.}

\item{removeInvalid}{Even if the original purpose of this function was to highlight}
}
\value{
If getInvalidData is FALSE, then the data is returned when the test
    is cleared, otherwise an error. If getInvalidData is TRUE, then the
    subset of the data that is invalid is returned.
}
\description{
This function checks whether the flags in the data are valid according to
the flagValidTable.
}

