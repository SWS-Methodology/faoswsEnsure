##' The function checks whether the transfer from parent to child commodity is
##' perform correctly.
##'
##' For more details of a transfer, see function
##' \code{faoswsProduction:transferParentToChild},
##'
##' @param parentData The animal slaughtered data from animal commodity.
##' @param childData The animal slaughtered data from meat commodity.
##' @param mappingTable The mapping table between the parent and the child.
##' @param returnData logical, whether the data should be returned
##' @param getInvalidData logical, this will skip the test and extract the data
##'     that is invalid.
##' @return If getInvalidData is FALSE, then the data is returned when the test
##'     is cleared, otherwise an error. If getInvalidData is TRUE, then the
##'     subset of the data that is invalid is returned.
##'
##' @export

ensureCorrectTransfer = function(parentData,
                                 childData,
                                 mappingTable,
                                 returnData = TRUE,
                                 getInvalidData = FALSE){

    ## Input check
    ##
    requiredColumn = c("geographicAreaM49",
                       "measuredItemCPC",
                       "measuredElement",
                       "timePointYears",
                       "Value",
                       "flagObservationStatus",
                       "flagMethod")

    ensureDataInput(data = childData,
                    requiredColumn = requiredColumn,
                    returnData = FALSE)
    ensureDataInput(data = parentData,
                    requiredColumn = requiredColumn,
                    returnData = FALSE)
    ensureDataInput(data = mappingTable,
                    requiredColumn = c("measuredItemParentCPC",
                                       "measuredItemChildCPC",
                                       "measuredElementParent",
                                       "measuredElementChild",
                                       "geographicAreaM49",
                                       "timePointYears",
                                       "share",
                                       "flagShare"),
                    returnData = FALSE)

    ## Convert the names of the table
    childDataCopy = copy(childData)
    parentDataCopy = copy(parentData)

    setnames(x = childDataCopy,
             old = c("measuredItemCPC", "measuredElement",
                     "Value", "flagObservationStatus", "flagMethod"),
             new = c("measuredItemChildCPC", "measuredElementChild",
                     paste0(c("Value", "flagObservationStatus", "flagMethod"),
                            "_child")))
    setnames(x = parentDataCopy,
             old = c("measuredItemCPC", "measuredElement",
                     "Value", "flagObservationStatus", "flagMethod"),
             new = c("measuredItemParentCPC", "measuredElementParent",
                     paste0(c("Value", "flagObservationStatus", "flagMethod"),
                            "_parent")))

    ## Merge the three input dataset
    childMergeCol = intersect(colnames(childDataCopy),
                              colnames(mappingTable))
    childDataMapped = merge(childDataCopy, mappingTable,
                            by = childMergeCol, all = TRUE)

    parentMergeCol = intersect(colnames(parentDataCopy),
                               colnames(mappingTable))
    parentDataMapped = merge(parentDataCopy, mappingTable,
                             by = parentMergeCol, all = TRUE)

    mergeAllCol = intersect(colnames(childDataMapped),
                            colnames(parentDataMapped))
    parentChildMergedData = merge(childDataMapped, parentDataMapped,
                                  by = mergeAllCol, all = TRUE)

    ## If share is missing, it is defaulted to 1
    parentChildMergedData[is.na(share), `:=`(c("share"), 1)]

    parentChildMergedData[, `:=`(c("discrepency", "tol"),
                                 list(Value_child - (Value_parent * share),
                                      Value_parent * 0.01))]

    invalidData = parentChildMergedData[discrepency > tol, ]

    if(getInvalidData){
        return(invalidData)
    } else {
        if(nrow(invalidData) > 0){
            stop("Transfer incorrect")
        }

        message("Data transferred  correctly")
        if(returnData)
            return(data)
    }



}
