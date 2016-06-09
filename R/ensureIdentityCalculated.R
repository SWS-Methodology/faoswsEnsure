##' Function to check whether the triplet (area harvested/production/yield) are
##' calculated whereever possible.
##'
##' @param data The data.table to be saved back to the SWS.
##' @param areaVar The column name corresponding to the area harvested.
##' @param yieldVar The column name corresponding to the yield.
##' @param prodVar The column name corresponding to produciton.
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


ensureIdentityCalculated = function(data,
                                    areaVar,
                                    yieldVar,
                                    prodVar,
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

    ## If the number of NA's is 1, then the identity is not calculated, as
    ## the number can be calculated by the other two non-missing values.
    containOneNA =
        (is.na(dataCopy[[areaVar]]) +
         is.na(dataCopy[[yieldVar]]) +
         is.na(dataCopy[[prodVar]])) == 1

    ## NOTE (Michael): However, yield can be a missing value when area
    ##                 harvested is zero.
    acceptableNACase =
        (dataCopy[[areaVar]] == 0 &
         is.na(dataCopy[[yieldVar]]))

    ## Return the index where identities are not calculated
    identityNotCalculated =
        setdiff(which(containOneNA), which(acceptableNACase))

    invalidData = dataCopy[identityNotCalculated, ]

    if(getInvalidData){
        if(!normalised){
            invalidData = denormalise(invalidData, denormalisedKey)
        }
        return(invalidData)
    } else {

        if(nrow(invalidData) > 0){
            print(identityNotCalculated)
            stop("Not all entries are calculated")
        }

        if(normalised){
            dataCopy = normalise(dataCopy)
        }
        message("All identity calculated")
        if(returnData)
            return(dataCopy)
    }
}
