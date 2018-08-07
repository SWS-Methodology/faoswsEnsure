##' Function to check whether the data will over write protected data.
##'
##' Certain data in the Statistical Working System should not be over
##' written by algorithms. Namely, official and semi-official
##' values. This function takes the data to be saved in the arguement
##' and pulls the exact same set of data from the data base, then
##' checks whether the matching set contains official or semi official
##' values.
##'
##'DUPLICATION FOR FBS PURPOSES (Used in faoswsStandardization plugin)
##'
##' @param data The data.table object containing data to be saved back to the
##'     database. The current implementation only accepts data in the normalised
##'     form.
##' @param domain The domain name in the SWS where the data will be saved.
##' @param dataset The dataset name in the SWS where the data will be saved.
##' @param areaVar The column name corresponding to the geographic area.
##' @param itemVar The column name corresponding to the commodity item.
##' @param elementVar The column name corresponding to the measured element.
##' @param yearVar The column name corresponding to the year.
##' @param flagObservationVar The column name corresponding to the observation
##'     status flag.
##' @param flagMethodVar The column name corresponding to the method flag.
##' @param flagTable The flag table containing the validity of the flags. see
##'     data{faoswsFlag::flagValidTable} for an example.
##' @param returnData logical, whether the data should be returned.
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
##'
##' @import faoswsFlag


ensureProtectedDataFBS = function (data, domain = "suafbs", dataset = "sua_unbalanced", 
          areaVar = "geographicAreaM49", itemVar = "measuredItemChildCPC", 
          elementVar = "measuredElement", yearVar = "timePointYears", 
          flagObservationVar = "flagObservationStatus", flagMethodVar = "flagMethod", 
          flagTable = flagValidTable, returnData = TRUE, normalised = TRUE, 
          denormalisedKey = "measuredElement", getInvalidData = FALSE) 
{
    dataCopy = copy(data)
    if (!normalised) {
        dataCopy = normalise(dataCopy)
    }
    setkeyv(dataCopy, col = c(areaVar, itemVar, elementVar, yearVar))
    ensureDataInput(data = dataCopy, requiredColumn = c(areaVar, 
                                                        itemVar, elementVar, yearVar), returnData = FALSE)
    if (NROW(dataCopy) > 0) {
        importCode = "5610"
        exportCode = "5910"
        productionCode="5510"
        seedCode="5525"
        stocksCode = "5071"
        
        message("Pulling data from SUA_unbalanced")
        
        geoDim = Dimension(name = "geographicAreaM49", keys = currentGeo)
        eleDim = Dimension(name = "measuredElementSuaFbs", keys = c(productionCode, seedCode, importCode, exportCode,stocksCode))
        
        itemDim = Dimension(name = "measuredItemFbsSua", keys = unique(dataCopy$measuredItemChildCPC))
        sua_un_key = DatasetKey(domain = "suafbs", dataset = "sua_unbalanced",
                                dimensions = list(
                                    geographicAreaM49 = geoDim,
                                    measuredElementSuaFbs = eleDim,
                                    measuredItemFbsSua = itemDim,
                                    timePointYears = timeDim)
        )
        dbData = GetData(sua_un_key)
        setkeyv(dbData, col = c(areaVar, "measuredItemFbsSua", "measuredElementSuaFbs", 
                                yearVar))
        matchSet = dbData[dataCopy, ]
        protectedFlagCombination = with(flagTable[flagTable$Protected, 
                                                  ], paste0("(", flagObservationStatus, ", ", flagMethod, 
                                                            ")"))
        matchSet[, `:=`(c("flagCombination"), paste0("(", flagObservationStatus, 
                                                     ", ", flagMethod, ")"))]
        invalidData = matchSet[matchSet$flagCombination %in% 
                                   protectedFlagCombination, ]
        if (getInvalidData) {
            if (!normalised) {
                invalidData = normalise(invalidData, denormalisedKey)
            }
            return(invalidData)
        }
        else {
            if (nrow(invalidData) > 0) 
                stop("Protected Data being over written!")
            if (!normalised) {
                dataCopy = denormalise(dataCopy, denormalisedKey)
            }
            message("Data can be safely saved back to database")
            if (returnData) 
                return(dataCopy)
        }
    }
    else {
        warning("Data to be saved contain no entry")
        return(dataCopy)
    }
}