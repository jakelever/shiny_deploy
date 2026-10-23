FROM rocker/shiny-verse:latest

############
# packages #
############

# Install system libraries (if needed for packages)
RUN apt-get update && sudo apt-get upgrade -y
RUN apt-get install -y \
    git curl vim gzip jq nginx \
    libcurl4-gnutls-dev \
    libssl-dev \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

#########
# shiny #
#########

# Install any required R packages
RUN R -e "install.packages(c('plotly', 'DT', 'reshape2', 'heatmaply', 'gplots'), repos='https://cloud.r-project.org/')"

RUN rm -rf /srv/shiny-server/*

# Set permissions
RUN chown -R shiny:shiny /srv/shiny-server

##############
# CancerMine #
##############

# Data comes from the latest version of each Zenodo dataset. The concept record ID (e.g. 1156241)
# redirects to the latest version. ADD re-fetches the record on every build, so the download step
# after it reruns (instead of using Docker's cache) whenever a new version has been published.
COPY download_zenodo_files.sh /usr/local/bin/download_zenodo_files.sh
RUN chmod +x /usr/local/bin/download_zenodo_files.sh

RUN git clone https://github.com/jakelever/cancermine.git
RUN cp -r cancermine/shiny /srv/shiny-server/cancermine
RUN echo "<script></script>" > /srv/shiny-server/cancermine/google-analytics.js
ADD https://zenodo.org/api/records/1156241 /tmp/cancermine_record.json
RUN download_zenodo_files.sh /tmp/cancermine_record.json /srv/shiny-server/cancermine cancermine_collated.tsv cancermine_sentences.tsv

#############
# CIViCmine #
#############

RUN git clone https://github.com/jakelever/civicmine.git
RUN cp -r civicmine/shiny /srv/shiny-server/civicmine
RUN echo "<script></script>" > /srv/shiny-server/civicmine/google-analytics.js
ADD https://zenodo.org/api/records/1472826 /tmp/civicmine_record.json
RUN download_zenodo_files.sh /tmp/civicmine_record.json /srv/shiny-server/civicmine civicmine_collated.tsv civicmine_sentences.tsv
# Likewise, re-fetching a CIViC nightly file means the CIViC download reruns when CIViC has changed
ADD https://civicdb.org/downloads/nightly/nightly-ClinicalEvidenceSummaries.tsv /tmp/civic_nightly_check.tsv
RUN cd /srv/shiny-server/civicmine/ && Rscript updateCIViC.R && rm /tmp/civic_nightly_check.tsv

RUN ls /srv/shiny-server/

###########################################
# Simple landing page (for health checks) #
###########################################
RUN mkdir -p /srv/landing
COPY landing.html /srv/landing/index.html

#########
# NGINX #
#########
RUN rm /etc/nginx/sites-enabled/default

COPY nginx-cancermine.conf /etc/nginx/sites-available/cancermine
RUN ln -s /etc/nginx/sites-available/cancermine /etc/nginx/sites-enabled/cancermine
COPY nginx-civicmine.conf /etc/nginx/sites-available/civicmine
RUN ln -s /etc/nginx/sites-available/civicmine /etc/nginx/sites-enabled/civicmine
COPY nginx-landing.conf /etc/nginx/sites-available/landing
RUN ln -s /etc/nginx/sites-available/landing /etc/nginx/sites-enabled/landing

##############
# running it #
##############

EXPOSE 80

# Copy startup script
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh
COPY warmup.sh /usr/local/bin/warmup.sh
RUN chmod +x /usr/local/bin/warmup.sh

# Start Shiny + nginx
CMD ["/usr/local/bin/start.sh"]
