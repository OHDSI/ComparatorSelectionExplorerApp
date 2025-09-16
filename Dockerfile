# Set base image

## Note that this build is primarily for use within results.ohdsi.org
FROM ohdsi/broadsea-shiny

ARG DEBIAN_FRONTEND=noninteractive
ARG CRAN=https://packagemanager.posit.co/cran/__linux__/focal/latest
ARG JAVA_PARAMS=-Xss100m

# Set an argument for the app name
ARG APP_NAME
# Set arguments for the GitHub branch and commit id abbreviation
ARG GIT_BRANCH='shiny_app_docker'
ARG GIT_COMMIT_ID_ABBREV

ENV DATABASECONNECTOR_JAR_FOLDER /root

# install additional required OS dependencies
RUN apt-get update && \
    apt-get install -y openjdk-8-jre && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Sets CRAN to latest (or user specified) version
RUN echo "options(repos=c(CRAN='$CRAN'))" >> /root/.Rprofile
# Specify java params
RUN echo "options(java.parameters = '$JAVA_PARAMS')" >> /root/.Rprofile
RUN R -e 'install.packages(c("remotes", "rJava", "dplyr", "DatabaseConnector", "shiny", "RSQLite", "pak"))'
# run java conf for r
RUN R CMD javareconf

COPY postgresql-42.7.3.jar /root/
# Alternatively - install
##RUN R -e "DatabaseConnector::downloadJdbcDrivers('postgresql', pathToDriver='/root')"
RUN R -e "remotes::install_github('OHDSI/ResultModelManager', update='always')"
# install git ref or branch
RUN R -e "ref <- Sys.getenv('GIT_COMMIT_ID_ABBREV', unset=Sys.getenv('GIT_BRANCH')); \
     remotes::install_github('OHDSI/ComparatorSelectionExplorer', ref=ref, update='always', dependencies = TRUE)"

WORKDIR /srv/shiny-server/

COPY start.sh /start.sh
RUN chmod +x /start.sh
COPY app.R ./

# Expose default Shiny app port
EXPOSE 3838