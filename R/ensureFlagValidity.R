##' This function checks whether the flags in the data are valid according to
##' the flagValidTable.
##'
##' @param data The data to be checked
##' @param flagObservationVar The column name corresponding to the observation
##'     status flag.
##' @param flagMethodVar The column name corresponding to the method flag.
##' @param flagTable The table containing valid/invalid flag combination. See
##'     \data{flagValidTable} in \pkg{faoswsFlag}
##' @param returnData logical, whether the data should be returned
##' @param normalised logical, whether the data is normalised
##' @param denormalisedKey optional, only required if the input data is not
##'     normalised.It is the name of the key that denormalises the data.
##' @return The original data is returned if all flags are valid, otherwise an
##'     error.
##'
##' @export

ensureFlagValidity = function(data,
                              flagObservationVar = "flagObservationStatus",
                              flagMethodVar = "flagMethod",
                              returnData = TRUE,
                              normalised = TRUE,
                              denormalisedKey = "measuredElement",
                              flagTable = flagValidTable){

    dataCopy = copy(data)
    ## Basic checks
    stopifnot(is(dataCopy, "data.table"))

    if(!normalised){
        dataCopy = normalise(dataCopy)
    }

    ensureDataInput(data = dataCopy,
                    requiredColumn = c(flagObservationVar, flagMethodVar),
                    returnData = FALSE)

    dataFlagCombination =
        unique(paste0("(", dataCopy[[flagObservationVar]], ", ",
                      dataCopy[[flagMethodVar]], ")"))

    tableFlagCombination =
        with(flagTable[flagTable$Valid, ],
             paste0("(", flagObservationStatus, ", ", flagMethod, ")"))

    invalidFlagCombinations = setdiff(dataFlagCombination, tableFlagCombination)

    if(length(invalidFlagCombinations) > 1){
        print(invalidFlagCombinations)
        stop("Invalid Combination flag exist, please provide correct combination")
    }
    if(!normalised){
        dataCopy = denormalise(dataCopy, denormalisedKey)
    }

    if(returnData)
        return(dataCopy)
}
