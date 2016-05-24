##' Function to check whether the production itdentity is satisfied.
##'
##' @param data The data.table to be saved back to the SWS.
##' @param areaVar The column name corresponding to the area harvested.
##' @param yieldVar The column name corresponding to the yield.
##' @param prodVar The column name corresponding to produciton.
##' @param conversion The conversion factor for calculating production.
##' @param returnData logical, whether the data should be returned.
##' @param normalised logical, whether the data is normalised
##' @param getInvalidData logical, this will skip the test and extract the data
##'     that is invalid.
##' @return If getInvalidData is FALSE, then the data is returned when the test
##'     is cleared, otherwise an error. If getInvalidData is TRUE, then the
##'     subset of the data that is invalid is returned.
##'
##' @export
##'

ensureProductionBalanced = function(data,
                                    areaVar,
                                    yieldVar,
                                    prodVar,
                                    conversion,
                                    returnData = TRUE,
                                    normalised = TRUE,
                                    getInvalidData = FALSE){

    dataCopy = copy(data)

    if(normalised){
        dataCopy = denormalise(dataCopy, "measuredElement")
    }

    ensureDataInput(data = dataCopy,
                    requiredColumn = c(areaVar, yieldVar, prodVar),
                    returnData = FALSE)


    productionDifference =
        abs(dataCopy[[areaVar]] * dataCopy[[yieldVar]] -
            dataCopy[[prodVar]] * conversion)

    ## NOTE (Michael): This is to account for difference due to
    ##                 rounding. The upper bound of the 1e-6 is the
    ##                 rounding performed by the system.
    allowedDifference = max(dataCopy[[areaVar]] * 1e-6, 1)
    imbalance = which(productionDifference > allowedDifference)

    invalidData = dataCopy[imbalance, ]
    if(getInvalidData){
        if(normalised){
            invalidData = normalise(invalidData)
        }
        return(invalidData)
    } else {
        if(nrow(invalidData) > 0){
            stop("Production is not balanced, the A * Y = P identity is not satisfied")
        }

        if(normalised){
            dataCopy = normalise(dataCopy)
        }

        if(returnData)
            return(dataCopy)
    }
}
