Introduction
============

This vignette provide an introduction to the testing framework designed
for R modules of the Statistical Working System.

Testing is an important aspect of all software development and
integrated data analysis. Without testing, one can never be sure the
reliability and validity of the end result.

Further, when new development are introduced, there is no way to
safeguard the program to continue provide the intended task.

The concept is so important that a paradigm emerged focusing on writing
the tests first prior to any development. This is known as [Test driven
development
(TDD)](https://en.wikipedia.org/wiki/Test-driven_development).

In this introduction, we will not delve into the whole process of TDD.
Rather, we will provide a brief explaination of the functionality of the
package then provide simple illustration of how to build input, output
and module tests for R modules.

The R modules should fulfill these three requirements before being
accepted as core module in the Statistical Working System.

Before we begin, let us generate a simulated dataset which we will use
to illustrate the functionalities and provide example for the rest of
the document.

    library(data.table)
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

Structure
---------

The purpose of the package is to standardise the test framework, and to
avoid duplication of identical functions. Further, similar tests can be
merged to form more generalised test in order to incorporate a broader
scope of the potential problems.

Developers of the Statistical Working System, should all contribut to
this package, share the experience and data problems faced by each
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
    Nevertheless, there are cases when we do not want to return the data
    and simply test whether the data is valid, then the arguement can
    simply be set to FALSE.

3.  The function must have an `getInvalidData` arguement and outputs the
    invalid data.

To illustrate the structure, an example is given below.

    library(faoswsEnsure)

    ## Loading required package: faoswsFlag

    ## Loading required package: faoswsUtil

This is the function to ensure the value of a variable is within the
feasible range.

    ensureValueRange

    ## function (data, ensureColumn, min = 0, max = Inf, includeEndPoint = TRUE, 
    ##     returnData = TRUE, getInvalidData = FALSE) 
    ## {
    ##     ensureDataInput(data = data, requiredColumn = ensureColumn, 
    ##         returnData = FALSE)
    ##     if (includeEndPoint) {
    ##         outOfRange = which(data[[ensureColumn]] < min | data[[ensureColumn]] > 
    ##             max)
    ##     }
    ##     else {
    ##         outOfRange = which(data[[ensureColumn]] <= min | data[[ensureColumn]] >= 
    ##             max)
    ##     }
    ##     invalidData = data[outOfRange, ]
    ##     if (getInvalidData) {
    ##         return(invalidData)
    ##     }
    ##     else {
    ##         if (nrow(invalidData) > 0) {
    ##             stop("Variable contains values out of range")
    ##         }
    ##         if (returnData) 
    ##             return(data)
    ##     }
    ## }
    ## <environment: namespace:faoswsEnsure>

1. Return error when data is invalid
------------------------------------

Here we test whether the data is between in the range \[0, 100\]
inclusive. The `indcludeEndPoint` arguement indicate that the value 0
and 100 are both acceptable. When `returnData` is TRUE, the original
data is returned when

    ensureValueRange(data = test_data,
                     ensureColumn = "Value",
                     min = 0,
                     max = 100,
                     includeEndPoint = TRUE,
                     returnData = TRUE,
                     getInvalidData = FALSE)

    ## Error in ensureValueRange(data = test_data, ensureColumn = "Value", min = 0, : Variable contains values out of range

2. Return the data
------------------

Here we take the same example data and the same test, but to render our
data valid, we expand the range to (-Inf, Inf).

As we can see from the printout, the data is now valid according to the
test and the original data is returned.

    ensureValueRange(data = test_data,
                     ensureColumn = "Value",
                     min = -Inf,
                     max = Inf,
                     includeEndPoint = TRUE,
                     returnData = TRUE,
                     getInvalidData = FALSE)

    ##     geographicAreaM49 measuredItemCPC measuredElement timePointYears
    ##  1:               100            0111            5510           2000
    ##  2:               100            0111            5510           2001
    ##  3:               100            0111            5510           2002
    ##  4:               100            0111            5510           2003
    ##  5:               100            0111            5510           2004
    ##  6:               100            0111            5510           2005
    ##  7:               100            0111            5510           2006
    ##  8:               100            0111            5510           2007
    ##  9:               100            0111            5510           2008
    ## 10:               100            0111            5510           2009
    ##          Value flagObservationStatus flagMethod
    ##  1: -1.1973136                     E          q
    ##  2:  0.1471663                     I          p
    ##  3: -0.8156824                     I          i
    ##  4:  0.3809114                     T          c
    ##  5:  1.1546866                                u
    ##  6:  1.3915975                                u
    ##  7: -0.6094934                     M          e
    ##  8:  0.1148457                     T          e
    ##  9:  0.9449499                                -
    ## 10:  0.4910301                     M          u

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

3. Obtain Invalid Data
----------------------

Testing for error is a preliminery, solving the problem is the goal. To
ease the debugging process, the function should be able to return the
invalid data.

Below we revert to the same test as in section one where there are
invalid data, instead of issuing the error, the invalid data is
returned.

Now the function returns value that are not within the \[0, 100\] range.

    ensureValueRange(data = test_data,
                     ensureColumn = "Value",
                     min = 0,
                     max = 100,
                     includeEndPoint = TRUE,
                     returnData = TRUE,
                     getInvalidData = TRUE)

    ##    geographicAreaM49 measuredItemCPC measuredElement timePointYears
    ## 1:               100            0111            5510           2000
    ## 2:               100            0111            5510           2002
    ## 3:               100            0111            5510           2006
    ##         Value flagObservationStatus flagMethod
    ## 1: -1.1973136                     E          q
    ## 2: -0.8156824                     I          i
    ## 3: -0.6094934                     M          e

Example
=======

In this section, we provide a minimal set of tests for each type of
validation that should be incorporated in all modules.

Input Validation
----------------

For input validation, the recommended tests are:

-   The feasible range of the variables.
-   The validity of flags.

Again an example is provided below, of course, there are additional
tests specific for each domain that should be incorporated. Take the
production domain for example, the production identity equation
(Production = Area Harvested x Yield) must be satisfied.

    library(magrittr)
    test_data %>%
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
                           getInvalidData = FALSE)

    ## Error in ensureFlagValidity(data = ., flagObservationVar = "flagObservationStatus", : Invalid Combination flag exist

Output Validation
-----------------

For the output validation, we recommend to test everything incorporated
in the input validation, but with the following addition test:

-   The destination data cell is not protected

<!-- -->

    test_data %>%
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
        ensureProtectedData(data = .,
                            domain = "agriculture",
                            dataset = "aproduction",
                            returnData = FALSE,
                            getInvalidData = FALSE)

    ## Error in ensureFlagValidity(data = ., flagObservationVar = "flagObservationStatus", : Invalid Combination flag exist

Module Validation
-----------------

Finally, all module should have module specific tests. These can be in
the form of:

-   non-regression tests: Tests to verify new functionality implemented
    has the intended effect.

-   non-regression tests: Tests to ensure new changes does not alter
    previous requirements.

In the case of production, a non-regression test is in place to ensure
all time series are imputed where available. In case of future changes
in methodology, the test will gurantee this requirement continue to be
fulfilled.

    library(faoswsProcessing)
    test_data %>%
        remove0M(data = .,
                 valueVars = "Value",
                 flagVars = "flagObservationStatus",
                 missingFlag = "M") %>%
        ensureTimeSeriesImputed(data = .,
                                key = c("geographicAreaM49",
                                        "measuredItemCPC",
                                        "measuredElement"),
                                valueColumn = "Value",
                                returnData = TRUE,
                                getInvalidData = FALSE)

    ## Error in ensureTimeSeriesImputed(data = ., key = c("geographicAreaM49", : Not all time series are imputed
