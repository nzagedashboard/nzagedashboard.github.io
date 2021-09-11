#!/bin/sh
cd ~/Documents/GitHub/nzagedashboard.github.io
/usr/local/bin/Rscript -e 'Sys.setenv(RSTUDIO_PANDOC="/Applications/RStudio.app/Contents/MacOS/pandoc");
                            source("~/Documents/GitHub/nzagedashboard.github.io/connect_API.R");
                            rmarkdown::render_site(encoding = "UTF-8");
                            rmarkdown::clean_site()'
git add -A
git commit -m "Autoupdate"
git push
