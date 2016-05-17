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
