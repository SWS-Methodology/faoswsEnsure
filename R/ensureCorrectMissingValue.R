##' The function ensure the missing value is correctly specified
##'
##' @param data The data to be saved back to the database.
##' @param valueVar The variable to be tested.
##' @param flagObservationStatusVar The flag associated with the value.
##' @param missingObservationFlag The value of the observation status flag which
##'     represents missing value.
##' @param returnData logical, whether the data should be returned
##' @param getInvalidData logical, this will skip the test and extract the data
##'     that is invalid.
##' @return If getInvalidData is FALSE, then the data is returned when the test
##'     is cleared, otherwise an error. If getInvalidData is TRUE, then the
##'     subset of the data that is invalid is returned.
##'
##' @export
##'
##'

ensureCorrectMissingValue = function(data,
                            valueVar = "Value",
                            flagObservationStatusVar = "flagObservationStatus",
                            missingObservationFlag = "M",
                            returnData = TRUE,
                            getInvalidData = FALSE){

    dataCopy = copy(data)
    ensureDataInput(data = dataCopy,
                    requiredColumn = c(valueVar, flagObservationStatusVar),
                    returnData = FALSE)

    invalidMissingValueIndex =
        which(dataCopy[[flagObservationStatusVar]] == missingObservationFlag &
              !(dataCopy[[valueVar]] %in% c(NA, 0)))

    invalidData = dataCopy[invalidMissingValueIndex, ]

    if(getInvalidData){
        return(invalidData)
    } else {
        if(nrow(invalidData) > 0){
            stop("Variable contains mis-specified missing value")
        }

        message("Data contains no mis-specified missing value")
        if(returnData)
            return(data)
    }
}
