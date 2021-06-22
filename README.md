# LEMMA-Shiny

A Shiny app to allow users to interact with the [LEMMA (Local Epidemic Modeling for Management and Action)](https://localepi.github.io/LEMMA/) 
R package via the web. 

The Shiny app can be accessed here: https://localepi.shinyapps.io/LEMMA-Shiny/

## To-do
  1. Sometimes the shinyapps.io version runs out of memory; this happens when running forecasts for many counties simultaneously. Solution one is to get a paid account with more memory. Solution two is to change the code of LEMMA.forecasts to only download once. This might not actually help much since when running counties in parallel it will get copied to each core anyway.
