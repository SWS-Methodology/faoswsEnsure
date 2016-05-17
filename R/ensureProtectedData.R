##' Function to check whether the data will over write protected data.
##'
##' Certain data in the Statistical Working System should not be over
##' written by algorithms. Namely, official and semi-official
##' values. This function takes the data to be saved in the arguement
##' and pulls the exact same set of data from the data base, then
##' checks whether the matching set contains official or semi official
##' values.
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
##' @param protectedFlag The set of flag values which corresponds to values that
##'     should not be over written.
##' @param returnData logical, whether the data should be returned.
##' @param normalised logical, whether the data is normalised
##' @param denormalisedKey optional, only required if the input data is not
##'     normalised.It is the name of the key that denormalises the data.
##'
##' @return If the data set passes the test, then the original data
##'     will be returned. Otherwise an error will be raised.
##'
##' @export
##'

ensureProtectedData = function(data,
                               domain = "agriculture",
                               dataset = "aproduction",
                               areaVar = "geographicAreaM49",
                               itemVar = "measuredItemCPC",
                               elementVar = "measuredElement",
                               yearVar = "timePointYears",
                               flagObservationVar = "flagObservationStatus",
                               flagMethodVar = "flagMethod",
                               protectedFlag = c("-", "q", "p", "h", "c"),
                               returnData = TRUE,
                               normalised = TRUE,
                               denormalisedKey = "measuredElement"){


    dataCopy = copy(data)
    setkeyv(dataCopy, col = c(areaVar, itemVar, elementVar, yearVar))

    if(!normalised){
        dataCopy = normalise(dataCopy)
    }

    ensureDataInput(data = dataCopy,
                    requiredColumn = c(areaVar, itemVar, elementVar, yearVar),
                    returnData = FALSE)



    if(NROW(dataCopy) > 0){
        newKey = DatasetKey(
            domain = domain,
            dataset = dataset,
            dimensions = list(
                Dimension(name = areaVar,
                          keys = as.character(unique(dataCopy[[areaVar]]))),
                Dimension(name = itemVar,
                          keys = as.character(unique(dataCopy[[itemVar]]))),
                Dimension(name = elementVar,
                          keys = as.character(unique(dataCopy[[elementVar]]))),
                Dimension(name = yearVar,
                          keys = as.character(unique(dataCopy[[yearVar]])))
            )
        )
        dbData = GetData(newKey)
        setkeyv(dbData, col = c(areaVar, itemVar, elementVar, yearVar))
        matchSet = dbData[dataCopy, ]
        protectedData = matchSet[matchSet[[flagMethodVar]] %in% protectedFlag &
                                 !(matchSet[[flagObservationVar]]  == "M"), ]
        if(NROW(protectedData) > 0)
            stop("Protected Data being over written!")
    } else {
        warning("Data to be saved contain no entry")
    }

    if(!normalised){
        dataCopy = denormalise(dataCopy, denormalisedKey)
    }

    if(returnData)
        return(dataCopy)
}
