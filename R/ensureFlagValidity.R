##' This function checks whether the flags in the data are valid according to
##' the flagValidTable.
##'
##' @param data The data to be checked
##' @param flagObservationVar The column name corresponding to the observation
##'     status flag.
##' @param flagMethodVar The column name corresponding to the method flag.
##' @param flagTable The table containing valid/invalid flag combination. See
##'     the dataset flagValidTable in \pkg{faoswsFlag}
##' @param returnData logical, whether the data should be returned
##' @param normalised logical, whether the data is normalised
##' @param denormalisedKey optional, only required if the input data is not
##'     normalised.It is the name of the key that denormalises the data.
##' @param getInvalidData logical, this will skip the test and extract the data
##'     that is invalid.
##' @return If getInvalidData is FALSE, then the data is returned when the test
##'     is cleared, otherwise an error. If getInvalidData is TRUE, then the
##'     subset of the data that is invalid is returned.
##'
##' @export
##' @import faoswsFlag faoswsUtil
##'

ensureFlagValidity = function(data,
                              flagObservationVar = "flagObservationStatus",
                              flagMethodVar = "flagMethod",
                              returnData = TRUE,
                              normalised = TRUE,
                              denormalisedKey = "measuredElement",
                              flagTable = flagValidTable,
                              getInvalidData = FALSE){

    dataCopy = copy(data)

    if(!normalised){
        dataCopy = normalise(dataCopy)
    }

    ensureDataInput(data = dataCopy,
                    requiredColumn = c(flagObservationVar, flagMethodVar),
                    returnData = FALSE)

    dataFlagCombination =
        paste0("(", dataCopy[[flagObservationVar]], ", ",
               dataCopy[[flagMethodVar]], ")")

    tableFlagCombination =
        with(flagTable[flagTable$Valid, ],
             paste0("(", flagObservationStatus, ", ", flagMethod, ")"))

    invalidFlagCombinations =
        which(!dataFlagCombination %in% unique(tableFlagCombination))
    invalidData = dataCopy[invalidFlagCombinations, ]

    if(getInvalidData){
        if(!normalised){
            invalidData = denormalise(invalidData, denormalisedKey)
        }
        return(invalidData)
    } else {
        if(length(invalidFlagCombinations) > 1){
            stop("Invalid Combination flag exist")
        }
        if(!normalised){
            dataCopy = denormalise(dataCopy, denormalisedKey)
        }

        if(returnData)
            return(dataCopy)
    }
}
