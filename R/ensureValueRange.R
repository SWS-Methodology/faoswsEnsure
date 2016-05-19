##' This function checks whether the values are within valid range
##'
##' @param data The data to be saved back to the database
##' @param ensureColumn The variable to be ensured.
##' @param min The minimum bound of the variable
##' @param max The maximum bound of the variable
##' @param includeEndPoint Whether the end point of minimum and maximum should
##'     be included.
##' @param returnData logical, whether the data should be returned
##' @return The same data if all time series are imputed, otherwise an error.
##'
##' @export
##'


ensureValueRange = function(data,
                            ensureColumn,
                            min = 0,
                            max = Inf,
                            includeEndPoint = TRUE,
                            returnData = TRUE){

    ensureDataInput(data = data,
                    requiredColumn = ensureColumn,
                    returnData = FALSE)

    if(includeEndPoint){
        outOfRange =
            which(data[[ensureColumn]] < min | data[[ensureColumn]] > max)
    } else {
        outOfRange =
            which(data[[ensureColumn]] <= min | data[[ensureColumn]] >= max)
    }

    if(length(outOfRange) > 0)
        stop("Variable contain value out of range")
    if(returnData)
        return(data)
}

