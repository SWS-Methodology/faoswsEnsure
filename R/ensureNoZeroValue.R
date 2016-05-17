ensureNoZeroValue = function(data,
                             noZeroValueColumn,
                             returnData = TRUE){
    ensureDataInput(data = data,
                    requiredColumn = noZeroValueColumn,
                    returnData = FALSE)

    if(any(data[[noZeroValueColumn]] == 0))
        stop("Variable contains zero value")
    if(returnData)
        return(data)
}
