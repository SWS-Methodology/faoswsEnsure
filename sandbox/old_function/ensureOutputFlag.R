##' This is a function to check whether the flags in the data confine
##' to expectation.
##'
##' @param data The data.table object to be checked
##' @param flagObservationVar The column name corresponding
##'     to the observation status flag.
##' @param flagObservationExpected The value of the observation
##'     status flag expected in the output.
##' @param flagMethodVar The column name corresponding to the
##'     method flag.
##' @param flagMethodExpected The value of the method flag expected in
##'     the output.
##' @param returnData logical, whether the data should be returned
##' @param normalised logical, whether the data is normalised
##' @param denormalisedKey optional, only required if the input data is not
##' @param getInvalidData logical, this will skip the test and extract the data
##'     that is invalid.
##' @return If getInvalidData is FALSE, then the data is returned when the test
##'     is cleared, otherwise an error. If getInvalidData is TRUE, then the
##'     subset of the data that is invalid is returned.
##'
##' @export
##'

ensureOutputFlags = function(data,
                             flagObservationVar = "flagObservationStatus",
                             flagObservationExpected,
                             flagMethodVar = "flagMethod",
                             flagMethodExpected,
                             returnData = TRUE,
                             normalised = TRUE,
                             denormalisedKey = "measuredElement",
                             getInvalidData = FALSE){
    dataCopy = copy(data)

    if(!normalised){
        dataCopy = normalise(dataCopy)
    }

    ensureDataInput(data = dataCopy,
                    requiredColumn = c(flagObservationVar, flagMethodVar),
                    returnData = FALSE)

    if(!all(data[[flagObservationVar]] %in%
            flagObservationExpected))
        stop("Incorrect Observation Flag")
    if(!all(data[[flagMethodVar]] %in% flagMethodExpected))
        stop("Incorrect Method Flag")

    if(!normalised){
        dataCopy = denormalise(dataCopy, denormalisedKey)
    }

    if(returnData)
        return(dataCopy)

}
