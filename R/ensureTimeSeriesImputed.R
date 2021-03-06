##' This function checks whether all time series within a dataset are imputed.
##'
##' @param data The data to be saved back to the database
##' @param key The key which splits the data into individual timeseries.
##'     Generally the set c('geographicAreaM49', 'measuredItemCPC',
##'     'measuredElement').
##' @param valueColumn The column which contains the numeric values.
##' @param observationFlagVar The variable name which corresponds to the
##'     observation status flag.
##' @param returnData logical, whether the data should be returned
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

ensureTimeSeriesImputed = function(data,
                                   key,
                                   valueColumn = "Value",
                                   observationFlagVar = "flagObservationStatus",
                                   returnData = TRUE,
                                   normalised = TRUE,
                                   denormalisedKey = "measuredElement",
                                   getInvalidData = FALSE){
    ## The number of missing values should be either zero or all
    ## missing.
    dataCopy = copy(data)

    if(!normalised){
        dataCopy = normalise(dataCopy)
    }

    ensureDataInput(data = dataCopy,
                    requiredColumn = c(key, valueColumn),
                    returnData = FALSE)

    ## NOTE (Michael): Check for (0, M) entry. Since (0, M) is actually a
    ##                 missing value, it will cause the test to fail as the
    ##                 value 0 is not a misssing value.
    if(nrow(dataCopy[dataCopy[[valueColumn]] == 0 &
                     dataCopy[[observationFlagVar]] == "M", ]) > 0)
        stop("(0, M) value exist, please remove them before proceeding with the test")

    check = dataCopy[, sum(is.na(.SD[[valueColumn]])) == 0 |
                       sum(is.na(.SD[[valueColumn]])) == .N,
                     by = c(key)]
    ## unimputedTimeSeries = which(!check$V1)
    ## unimputedIndex = check[unimputedTimeSeries, key, with = FALSE]
    unimputedIndex = check[!check$V1, ]
    setkeyv(unimputedIndex, key)
    setkeyv(dataCopy, key)

    invalidData = dataCopy[unimputedIndex, ]

    if(getInvalidData){
        if(!normalised){
            invalidData = denormalise(invalidData, denormalisedKey)
        }
        return(invalidData)
    } else {
        if(nrow(invalidData) > 0){
            stop("Not all time series are imputed")
        }
        if(!normalised){
            dataCopy = denormalise(dataCopy, denormalisedKey)
        }

        message("All time series imputed where available")
        if(returnData)
            return(dataCopy)
    }
}
