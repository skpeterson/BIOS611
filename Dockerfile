# docker image (tidyverse)
FROM rocker/verse

# Update and install standard utilities
RUN apt update && apt install -y \
    man \
    wget \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install the necessary packages for the analysis
RUN R -e "install.packages(c('here','NatParksPalettes','cowplot','ggridges'))"

# Install remotes to allow installation from GitHub
RUN R -e "install.packages('remotes')"

# Install ggsankey from GitHub
RUN R -e "remotes::install_github('davidsjoberg/ggsankey')"

# Install Jupyter and other Python packages
RUN pip3 install jupyter

# Set password for rstudio user 
RUN echo "rstudio:benson" | chpasswd

# Create the directory for RStudio preferences
RUN mkdir -p /home/rstudio/.config/rstudio

# Set Rstudio preferences using a .json file
RUN echo '{"editor_theme": "Material", "rainbow_parentheses": true, "highlight_r_function_calls": true}' \
  > /home/rstudio/.config/rstudio/rstudio-prefs.json

# Create a script to start both RStudio Server and Jupyter Notebook
RUN echo '#!/bin/bash\n'\
'# Start RStudio Server in the background\n'\
'/usr/lib/rstudio-server/bin/rserver &\n'\
'# Start Jupyter Notebook as rstudio user\n'\
'su - rstudio -c "jupyter-notebook --ip=0.0.0.0 --port=8888 --no-browser" &\n' \
'# Keep the container running by tailing a log file or running an infinite loop\n'\
'tail -f /dev/null' > /usr/local/bin/start_services.sh

# Make the script executable
RUN chmod +x /usr/local/bin/start_services.sh

# Ensure permissions for rstudio user
RUN chown -R rstudio:rstudio /home/rstudio

# Set the working directory
WORKDIR /home/rstudio/work

# Set the default command to run the services
CMD ["/usr/local/bin/start_services.sh"]

