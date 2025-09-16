#!/bin/sh
# Run the Shiny app
R -e "shiny::runApp('/srv/shiny-server/', host = '0.0.0.0', port = 3838)"