##' Function to ensure the data input is correct.
##'
##' @param data The data to be checked.
##' @param requiredColumn The required column names the data must contain.
##' @param returnData logical, whether the data should be returned for pipe.
##'
##' @return If the data passes the check, the original data is returned,
##'     otherwise an error.
##'
##' @export

ensureDataInput = function(data,
                           requiredColumn = NULL,
                           returnData = TRUE){

    if(!is(data, "data.table"))
        stop("Input data is not a data.table object")

    if(!is.null(colnames)){
        missingColumn = requiredColumn[!requiredColumn %in% colnames(data)]
        if(length(missingColumn) > 0){
            missingColumnMsg = paste0(missingColumn, collapse = "\n\t")
            stop("The following required column not in input data",
                 missingColumnMsg)
            }
    }
    if(returnData)
        return(data)
}
