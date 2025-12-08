FROM rocker/shiny-verse:latest

# Install system libraries (if needed for packages)
RUN apt-get update && sudo apt-get upgrade -y
RUN apt-get install -y \
    git curl vim gzip \
    libcurl4-gnutls-dev \
    libssl-dev \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

# Install any required R packages
RUN R -e "install.packages(c('plotly', 'DT', 'reshape2', 'heatmaply'), repos='https://cloud.r-project.org/')"

RUN rm -rf /srv/shiny-server/*

# Copy your Shiny app into the image
# COPY . /srv/shiny-server/

# Set permissions
RUN chown -R shiny:shiny /srv/shiny-server

RUN git clone https://github.com/jakelever/cancermine.git
RUN cp -r cancermine/shiny /srv/shiny-server/cancermine
RUN echo "<script></script>" > /srv/shiny-server/cancermine/google-analytics.js
RUN curl -o /srv/shiny-server/cancermine/cancermine_collated.tsv https://zenodo.org/records/7689627/files/cancermine_collated.tsv
RUN curl -o /srv/shiny-server/cancermine/cancermine_sentences.tsv https://zenodo.org/records/7689627/files/cancermine_sentences.tsv

RUN git clone https://github.com/jakelever/civicmine.git
RUN cp -r civicmine/shiny /srv/shiny-server/civicmine
RUN echo "<script></script>" > /srv/shiny-server/civicmine/google-analytics.js
RUN curl -o /srv/shiny-server/civicmine/civicmine_collated.tsv.gz https://zenodo.org/records/7689629/files/civicmine_collated.tsv.gz
RUN curl -o /srv/shiny-server/civicmine/civicmine_sentences.tsv.gz https://zenodo.org/records/7689629/files/civicmine_sentences.tsv.gz
RUN gunzip /srv/shiny-server/civicmine/civicmine_collated.tsv.gz
RUN gunzip /srv/shiny-server/civicmine/civicmine_sentences.tsv.gz
RUN cd /srv/shiny-server/civicmine/ && Rscript updateCIViC.R

RUN ls /srv/shiny-server/

# COPY shiny-server.conf /etc/shiny-server/shiny-server.conf

# Expose the port the app runs on
EXPOSE 3838

# Start Shiny Server
CMD ["/usr/bin/shiny-server"]
