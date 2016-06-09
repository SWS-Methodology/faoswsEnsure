##' This function checks whether the values are within valid range
##'
##' @param data The data to be saved back to the database
##' @param ensureColumn The variable to be ensured.
##' @param min The minimum bound of the variable
##' @param max The maximum bound of the variable
##' @param includeEndPoint Whether the end point of minimum and maximum should
##'     be included.
##' @param returnData logical, whether the data should be returned
##' @param getInvalidData logical, this will skip the test and extract the data
##'     that is invalid.
##' @return If getInvalidData is FALSE, then the data is returned when the test
##'     is cleared, otherwise an error. If getInvalidData is TRUE, then the
##'     subset of the data that is invalid is returned.
##'
##' @export
##'


ensureValueRange = function(data,
                            ensureColumn,
                            min = 0,
                            max = Inf,
                            includeEndPoint = TRUE,
                            returnData = TRUE,
                            getInvalidData = FALSE){
    dataCopy = copy(data)
    ensureDataInput(data = dataCopy,
                    requiredColumn = ensureColumn,
                    returnData = FALSE)

    if(includeEndPoint){
        outOfRange =
            which(dataCopy[[ensureColumn]] < min | dataCopy[[ensureColumn]] > max)
    } else {
        outOfRange =
            which(dataCopy[[ensureColumn]] <= min | dataCopy[[ensureColumn]] >= max)
    }
    invalidData = dataCopy[outOfRange, ]

    if(getInvalidData){
        return(invalidData)
    } else {
        if(nrow(invalidData) > 0){
            stop("Variable contains values out of range")
        }

        message("All values withing specified range")
        if(returnData)
            return(dataCopy)
    }
}

