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
##'
##' @return If the data passes the check, the original data is returned,
##'     otherwise an error.
##'
##' @export

ensureNoConflictingZero = function(data,
                                   valueColumn1,
                                   valueColumn2,
                                   returnData = TRUE,
                                   normalised = TRUE,
                                   denormaliseKey = "measuredElement"){
    dataCopy = copy(data)
    if(normalised){
        dataCopy = denormalise(dataCopy, denormaliseKey = denormaliseKey)
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
        which(productionAreaHarvestedNotMissing &
              productionZeroAreaNonZero &
              productionNonZeroAreaHarvestedZero)
    if(length(conflictProductionAreaHarvested) > 0)
        stop("Conflict value exist in production area harvested")

    if(normalised){
        dataCopy = normalise(dataCopy)
    }

    if(returnData)
        return(dataCopy)
}
