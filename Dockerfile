# choose docker image (this one is the tidyverse one)
FROM rocker/verse

RUN apt update && apt install -y man && rm -rf /var/lib/apt/lists/*

# install the necessary packages for the analysis
RUN R -e "install.packages(c('here','NatParksPalettes'))"

# Create the directory for RStudio preferences
RUN mkdir -p /home/rstudio/.config/rstudio

# set Rstudio preferences using a .json file
RUN echo '{"editor_theme": "Material", "rainbow_parentheses": true, "highlight_r_function_calls": true}' \
  > /home/rstudio/.config/rstudio/rstudio-prefs.json

# set the default working dir 
WORKDIR /home/rstudio/work
