##' Function to ensure that two value column does not contain conflicting zero
##' values.
##'
##' In the production domain, when production is zero, area harvested can not be
##' zero by definition and vice versa.
##'
##' @param data The data to be checked.
##' @param valueColumn1 The first variable for comparison.
##' @param valueColumn2 The second variable for comparison.
##' @param returnData logical, whether the data should be returned for pipe.
##' @param normalised logical, whether the data is normalised.
##' @param denormalisedKey optional, only required if the input data is not
##'     normalised.It is the name of the key that denormalises the data.
##' @param getInvalidData logical, this will skip the test and extract the data
##'     that is invalid.
##' @return If getInvalidData is FALSE, then the data is returned when the test
##'     is cleared, otherwise an error. If getInvalidData is TRUE, then the
##'     subset of the data that is invalid is returned.
##'
##' @export

ensureNoConflictingZero = function(data,
                                   valueColumn1,
                                   valueColumn2,
                                   returnData = TRUE,
                                   normalised = TRUE,
                                   denormalisedKey = "measuredElement",
                                   getInvalidData = FALSE){
    dataCopy = copy(data)
    if(normalised){
        dataCopy = denormalise(dataCopy, denormaliseKey = denormalisedKey)
    }

    ensureDataInput(dataCopy,
                    requiredColumn = c(valueColumn1, valueColumn2),
                    returnData = FALSE)

    bothValueNonMissing =
        !is.na(dataCopy[[valueColumn1]]) &
        !is.na(dataCopy[[valueColumn2]])
    value1ZeroValue2NonZero =
        dataCopy[[valueColumn1]] == 0 &
        dataCopy[[valueColumn2]] != 0
    value1NonZeroValue2Zero =
        dataCopy[[valueColumn1]] != 0 &
        dataCopy[[valueColumn2]] == 0

    conflictingZeroValues =
        which(bothValueNonMissing &
              value1ZeroValue2NonZero &
              value1NonZeroValue2Zero)

    invalidData = dataCopy[conflictingZeroValues, ]

    if(getInvalidData){
        if(!normalised){
            invalidData = normalise(invalidData)
        }
        return(invalidData)
    } else {
        if(nrow(invalidData) > 0)
            stop("Conflict value exist in production area harvested")

        if(normalised){
            dataCopy = normalise(dataCopy)
        }

        if(returnData)
            return(dataCopy)
    }
}
