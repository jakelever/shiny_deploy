FROM rocker/shiny:latest

# Install system libraries (if needed for packages)
RUN apt-get update && apt-get install -y \
    libcurl4-gnutls-dev \
    libssl-dev \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

# Install any required R packages
RUN R -e "install.packages(c('tidyverse', 'shiny', 'data.table'), repos='https://cloud.r-project.org/')"

# Copy your Shiny app into the image
COPY . /srv/shiny-server/

# Set permissions
RUN chown -R shiny:shiny /srv/shiny-server

# Expose the port the app runs on
EXPOSE 3838

# Start Shiny Server
CMD ["/usr/bin/shiny-server"]
