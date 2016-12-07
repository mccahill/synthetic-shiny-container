# shiny-synthetic-container

A Docker container for running a Shiny app providing a user interface to
construct regression models that use differential privacy and synthetic
data setsd to limit data 'leakage'. 

This is a component of the application found here: https://github.com/mccahill/synthetic-data

You will almost certainly want to run this Docker container behind an 
Nginx proxy to provide https support. 

See the "Run a large scale RStudio container farm" section of the readme 
here: https://github.com/mccahill/docker-rstudio for an example of how that 
might be done
