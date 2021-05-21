# LEMMA

LEMMA (Local Epidemic Modeling for Management and Action) is designed to provide regional (e.g. city or county-level) projections of the SARS-CoV-2 (COVID-19) epidemic under various scenarios. Daily projections with uncertainty bounds are made for hospitalizations, ICU use active cases, and total cases. As detailed below, LEMMA allows for a range of user-specified parameterizations (including on the model structure) and is fit using case series data of COVID-19 hospital and ICU census, hospital admissions, deaths, cases and seroprevalence.

As of LEMMA 2.0, vaccine and variant modeling is now supported - see documentation at [LEMMA's website](https://localepi.github.io/LEMMA/).

Forecasts and scenarios for California counties:

  * [County Forecasts](https://github.com/LocalEpi/LEMMA-Forecasts/tree/master/Forecasts)
  * [County Scenarios](https://github.com/LocalEpi/LEMMA-Forecasts/tree/master/Scenarios)

# Compartmental model used in LEMMA

The LEMMA model is based on the [Santa Cruz County COVID-19 Model](https://github.com/jpmattern/seir-covid19) and is a discrete time SEIR model. The model is fit to data using [Stan](https://mc-stan.org/).

![compartment](figures/SEIRModel.png "SEIR compartmental model")

![legend](figures/SEIRModelLegend.png "legend")

# FAQ

[https://localepi.github.io/LEMMA/articles/faq.html](https://localepi.github.io/LEMMA/articles/faq.html)

# Contributors

LEMMA is a collaborative effort between experts in Medicine, Public Health, and Data Science, including but not limited to

  * Joshua Schwab - UC Berkeley
  * Laura B. Balzer - UMass Amherst
  * Elvin Geng - Washington University
  * Diane Havlir - UC San Francisco
  * James Peng - UC San Francisco
  * Sophia Tan - UC Berkeley
  * Maya L. Petersen - UC Berkeley

We have moved our model fitting from R to Stan. Our Stan implementation is based on the “Santa Cruz County COVID-19 Model” [https://github.com/jpmattern/seir-covid19](https://github.com/jpmattern/seir-covid19) by Jann Paul Mattern (UC Santa Cruz) and Mikala Caton (Santa Cruz County Health Services Agency). We are very grateful to Paul and Mikala for generously sharing their code and helping us.