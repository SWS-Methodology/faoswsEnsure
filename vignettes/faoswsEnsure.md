Introduction
============

This vignette provide a gentle introduction to the testing framework
designed for R modules of the Statistical Working System.

Testing is an crucial dimension of all software development and
integrated data analysis. Without testing, one can never be certain
ofthe reliability and validity of the end result. Moreover, when new
developments are introduced, there exist no protection to safeguard the
program to continue to perform the intended task.

The concept is so important that a paradigm emerged focusing on writing
the tests first prior to any development. This is known as [Test driven
development
(TDD)](https://en.wikipedia.org/wiki/Test-driven_development).

In this introduction, we will provide a brief explaination of the
functionality and standards of the package then provide simple
illustration of how to build input, output and module tests for R
modules.

It is necessary for an R modules to embrace all three requirement tests
before being accepted as core module in the Statistical Working System.

------------------------------------------------------------------------

Before we begin, let us generate a simulated dataset which we will use
to illustrate the functionalities and provide example for the rest of
the document.

    library(data.table)
    set.seed(587)
    test_data =
        data.table(geographicAreaM49 = rep("100", 10),
                   measuredItemCPC = rep("0111", 10),
                   measuredElement = rep("5510", 10),
                   timePointYears = as.character(2000:2009),
                   Value = rnorm(10),
                   flagObservationStatus =
                       c("E", "I", "I", "T", "", "", "M", "T", "", "M"),
                   flagMethod =
                       c("q", "p", "i", "c", "u", "u", "e", "e", "-", "u"))

------------------------------------------------------------------------

Structure
=========

The purpose of the package is to standardise the test framework, and to
avoid duplication of identical functions. Further, similar tests can be
merged to form more generalised test in order to incorporate a broader
scope of potential problems.

Developers of the Statistical Working System, should all contribut to
this package, share the experience and data problems present in each
individual modules. This will eliminate the chances of solving the same
problem accross different projects.

To extend the functionality of the package, a new function must adhere
to the standard of the package and have the following component.

1.  When an error is detected, an error should be thrown with the
    `stop` function.

2.  The function should have a `returnData` arguement, when set to TRUE
    the original data should be returned if no error was detected for
    sequential tests. This is based on the same philosphy as the
    [ensurer](https://cran.r-project.org/web/packages/ensurer/vignettes/ensurer.html) package.
    Nevertheless, there are cases where we do not want to return the
    data and simply test whether the data is valid, then the arguement
    can simply be set to FALSE.

3.  The function must have an `getInvalidData` arguement and returns the
    invalid data if any.

To illustrate the structure, an example is given below.

    library(faoswsEnsure)
    #> Loading required package: faoswsFlag
    #> Loading required package: faoswsUtil

This is a function in the package to ensure the value of a variable is
confines to the specified feasible range.

    ensureValueRange
    #> function (data, ensureColumn, min = 0, max = Inf, includeEndPoint = TRUE, 
    #>     returnData = TRUE, getInvalidData = FALSE) 
    #> {
    #>     dataCopy = copy(data)
    #>     ensureDataInput(data = dataCopy, requiredColumn = ensureColumn, 
    #>         returnData = FALSE)
    #>     if (includeEndPoint) {
    #>         outOfRange = which(dataCopy[[ensureColumn]] < min | dataCopy[[ensureColumn]] > 
    #>             max)
    #>     }
    #>     else {
    #>         outOfRange = which(dataCopy[[ensureColumn]] <= min | 
    #>             dataCopy[[ensureColumn]] >= max)
    #>     }
    #>     invalidData = dataCopy[outOfRange, ]
    #>     if (getInvalidData) {
    #>         return(invalidData)
    #>     }
    #>     else {
    #>         if (nrow(invalidData) > 0) {
    #>             stop("Variable contains values out of range")
    #>         }
    #>         message("All values withing specified range")
    #>         if (returnData) 
    #>             return(dataCopy)
    #>     }
    #> }
    #> <environment: namespace:faoswsEnsure>

1. Return error when data is invalid
------------------------------------

Here we test whether the data is between in the range **\[0, 100\]**
inclusive. The `indcludeEndPoint` arguement indicate that the value 0
and 100 are both acceptable. Since our variable contains data contains
negative value, the test is not passed and an error is thrown.

    ensureValueRange(data = test_data,
                     ensureColumn = "Value",
                     min = 0,
                     max = 100,
                     includeEndPoint = TRUE,
                     returnData = TRUE,
                     getInvalidData = FALSE)
    #> Error in ensureValueRange(data = test_data, ensureColumn = "Value", min = 0, : Variable contains values out of range

2. Return the data
------------------

Here we take the same example data and the same test, but to render our
data valid, we expand the range to **(-Inf, Inf)**.

As we can see from the printout, the data is now valid according to the
test and the complete original data is returned.

    ensureValueRange(data = test_data,
                     ensureColumn = "Value",
                     min = -Inf,
                     max = Inf,
                     includeEndPoint = TRUE,
                     returnData = TRUE,
                     getInvalidData = FALSE)
    #> All values withing specified range
    #>     geographicAreaM49 measuredItemCPC measuredElement timePointYears
    #>  1:               100            0111            5510           2000
    #>  2:               100            0111            5510           2001
    #>  3:               100            0111            5510           2002
    #>  4:               100            0111            5510           2003
    #>  5:               100            0111            5510           2004
    #>  6:               100            0111            5510           2005
    #>  7:               100            0111            5510           2006
    #>  8:               100            0111            5510           2007
    #>  9:               100            0111            5510           2008
    #> 10:               100            0111            5510           2009
    #>           Value flagObservationStatus flagMethod
    #>  1: -1.31573969                     E          q
    #>  2: -0.09034184                     I          p
    #>  3:  1.20381792                     I          i
    #>  4:  1.91887514                     T          c
    #>  5:  0.05740636                                u
    #>  6:  2.26655202                                u
    #>  7:  0.28491171                     M          e
    #>  8:  0.12491003                     T          e
    #>  9: -1.52579303                                -
    #> 10: -0.07296137                     M          u

We can also silence the output by setting the `returnData` arguement to
FALSE.

This time, the data is valid and thus no error is issued but the data is
no longer returned.

    ensureValueRange(data = test_data,
                     ensureColumn = "Value",
                     min = -Inf,
                     max = Inf,
                     includeEndPoint = TRUE,
                     returnData = FALSE,
                     getInvalidData = FALSE)
    #> All values withing specified range

3. Obtain Invalid Data
----------------------

Testing for error is a preliminery, solving the problem is the goal. To
ease the debugging process, the function should be able to return the
invalid data.

In addition, when developing validation modules, we may want to collect
all the invalid data instead of terminating the program.

Below we revert to the same test as in section one where there are
invalid data, instead of issuing the error, the invalid data is returned
by specify `getInvalidData` to FALSE.

Now the function returns value that are not within the **\[0, 100\]**
range.

    ensureValueRange(data = test_data,
                     ensureColumn = "Value",
                     min = 0,
                     max = 100,
                     includeEndPoint = TRUE,
                     returnData = TRUE,
                     getInvalidData = TRUE)
    #>    geographicAreaM49 measuredItemCPC measuredElement timePointYears
    #> 1:               100            0111            5510           2000
    #> 2:               100            0111            5510           2001
    #> 3:               100            0111            5510           2008
    #> 4:               100            0111            5510           2009
    #>          Value flagObservationStatus flagMethod
    #> 1: -1.31573969                     E          q
    #> 2: -0.09034184                     I          p
    #> 3: -1.52579303                                -
    #> 4: -0.07296137                     M          u

------------------------------------------------------------------------

Example
=======

In this section, we provide a minimal set of tests for each type of
validation that should be incorporated in all modules.

Input Validation
----------------

For input validation, the recommended tests are:

-   The feasible range of the variables.
-   The validity of flags.
-   Missing values are correctly specified

Again an example is provided below, of course, there are additional
tests specific for each domain that should be incorporated. Take the
production domain for example, the production identity equation
(Production = Area Harvested x Yield) must be satisfied.

    library(magrittr)
    test_data %>%
        ensureValueRange(data = .,
                         ensureColumn = "Value",
                         min = 0,
                         max = Inf,
                         includeEndPoint = TRUE,
                         returnData = TRUE,
                         getInvalidData = FALSE) %>%
        ensureFlagValidity(data = .,
                           flagObservationVar = "flagObservationStatus",
                           flagMethodVar = "flagMethod",
                           returnData = TRUE,
                           getInvalidData = FALSE) %>%
        ensureCorrectMissingValue(data = .,
                                  valueVar = "Value",
                                  flagObservationStatusVar = "flagObservationStatus",
                                  missingObservationFlag = "M",
                                  returnData = TRUE,
                                  getInvalidData = FALSE)
    #> Error in ensureValueRange(data = ., ensureColumn = "Value", min = 0, max = Inf, : Variable contains values out of range

Looks like our data is really dirty! Maybe we should fix it.

    corrected_data = copy(test_data)

    ## Make all value positive
    corrected_data[, `:=`("Value", abs(Value))]

    ## Correct flags
    corrected_data[, `:=`(c("flagObservationStatus", "flagMethod"), list("I", "e"))]

    ## Correct Missing value
    corrected_data[flagObservationStatus == "M", `:=`("Value", NA)]

Lets perform the tests again.

    corrected_data %>%
        ensureValueRange(data = .,
                         ensureColumn = "Value",
                         min = 0,
                         max = Inf,
                         includeEndPoint = TRUE,
                         returnData = TRUE,
                         getInvalidData = FALSE) %>%
        ensureFlagValidity(data = .,
                           flagObservationVar = "flagObservationStatus",
                           flagMethodVar = "flagMethod",
                           returnData = TRUE,
                           getInvalidData = FALSE) %>%
        ensureCorrectMissingValue(data = .,
                                  valueVar = "Value",
                                  flagObservationStatusVar = "flagObservationStatus",
                                  missingObservationFlag = "M",
                                  returnData = TRUE,
                                  getInvalidData = FALSE)
    #> All values withing specified range
    #> All flag are valid
    #> Data contains no mis-specified missing value
    #>     geographicAreaM49 measuredItemCPC measuredElement timePointYears
    #>  1:               100            0111            5510           2000
    #>  2:               100            0111            5510           2001
    #>  3:               100            0111            5510           2002
    #>  4:               100            0111            5510           2003
    #>  5:               100            0111            5510           2004
    #>  6:               100            0111            5510           2005
    #>  7:               100            0111            5510           2006
    #>  8:               100            0111            5510           2007
    #>  9:               100            0111            5510           2008
    #> 10:               100            0111            5510           2009
    #>          Value flagObservationStatus flagMethod
    #>  1: 1.31573969                     I          e
    #>  2: 0.09034184                     I          e
    #>  3: 1.20381792                     I          e
    #>  4: 1.91887514                     I          e
    #>  5: 0.05740636                     I          e
    #>  6: 2.26655202                     I          e
    #>  7: 0.28491171                     I          e
    #>  8: 0.12491003                     I          e
    #>  9: 1.52579303                     I          e
    #> 10: 0.07296137                     I          e

Now it would appear that the data is valid and we are ready to proceed
to with data processing and analysis.

Output Validation
-----------------

For the output validation, we recommend to test everything incorporated
in the input validation, but with the following addition test:

-   The destination data cell is not protected

The following code is not executed as to determine whether a destination
cell is protected, connection to the Statistical Working System is
required.

    corrected_data %>%
        ensureValueRange(data = .,
                         ensureColumn = "Value",
                         min = -Inf,
                         max = Inf,
                         includeEndPoint = TRUE,
                         returnData = TRUE,
                         getInvalidData = FALSE) %>%
        ensureFlagValidity(data = .,
                           flagObservationVar = "flagObservationStatus",
                           flagMethodVar = "flagMethod",
                           returnData = TRUE,
                           getInvalidData = FALSE) %>%
        ensureCorrectMissingValue(data = .,
                                  valueVar = "Value",
                                  flagObservationStatusVar = "flagObservationStatus",
                                  missingObservationFlag = "M"
                                  returnData = TRUE,
                                  getInvalidData = FALSE) %>%
        ensureProtectedData(data = .,
                            domain = "agriculture",
                            dataset = "aproduction",
                            returnData = FALSE,
                            getInvalidData = FALSE)

Module Validation
-----------------

Finally, all module should have module specific tests. These can be in
the form of:

-   non-regression tests: Tests to verify new functionality implemented
    has the intended effect.

-   regression tests: Tests to ensure new changes does not alter
    previous requirements.

In the case of production, one of the regression test is to ensure all
time series are imputed where available. In case of future changes in
methodology, the test will gurantee this requirement continue to be
fulfilled.

    library(faoswsProcessing)
    corrected_data %>%
        ensureTimeSeriesImputed(data = .,
                                key = c("geographicAreaM49",
                                        "measuredItemCPC",
                                        "measuredElement"),
                                valueColumn = "Value",
                                returnData = TRUE,
                                getInvalidData = FALSE)
    #> All time series imputed where available
    #>     geographicAreaM49 measuredItemCPC measuredElement timePointYears
    #>  1:               100            0111            5510           2000
    #>  2:               100            0111            5510           2001
    #>  3:               100            0111            5510           2002
    #>  4:               100            0111            5510           2003
    #>  5:               100            0111            5510           2004
    #>  6:               100            0111            5510           2005
    #>  7:               100            0111            5510           2006
    #>  8:               100            0111            5510           2007
    #>  9:               100            0111            5510           2008
    #> 10:               100            0111            5510           2009
    #>          Value flagObservationStatus flagMethod
    #>  1: 1.31573969                     I          e
    #>  2: 0.09034184                     I          e
    #>  3: 1.20381792                     I          e
    #>  4: 1.91887514                     I          e
    #>  5: 0.05740636                     I          e
    #>  6: 2.26655202                     I          e
    #>  7: 0.28491171                     I          e
    #>  8: 0.12491003                     I          e
    #>  9: 1.52579303                     I          e
    #> 10: 0.07296137                     I          e
