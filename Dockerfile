# Base Image
FROM rocker/shiny-verse

# Install packages
RUN apt-get update -qq && apt-get -y --no-install-recommends install \
libpq-dev &&\
apt-get install -y gdal-bin &&\
apt-get install libudunits2-dev -y

RUN R -e 'install.packages(c("leaflet","shinycssloaders","sf","AzureStor","shinydashboard","plotly","htmlwidgets","shinyWidgets","DT","shinyjs","shinyalert","sparkline","shinythemes","tigris"))'


# Install Packages from GH
RUN R -e 'devtools::install_github("CompassRed/CRplot")'
RUN R -e 'devtools::install_github("RinteRface/shinydashboardPlus")'

# Make port 3838 reachable
EXPOSE 3838

# Copy the app to the image
RUN mkdir /root/project_ditto
COPY . /root/project_ditto

# Make all app files readable
RUN chmod -R +r /root/project_ditto/

# Copy Rprofile to the image
COPY Rprofile.site /usr/lib/R/etc/

CMD ["R", "-e", "shiny::runApp('/root/project_ditto',port = 3838L, host = '0.0.0.0')"]