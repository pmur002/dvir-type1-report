
# Base image
FROM ubuntu:20.04
MAINTAINER Paul Murrell <paul@stat.auckland.ac.nz>

# add CRAN PPA
RUN apt-get update && apt-get install -y apt-transport-https gnupg ca-certificates software-properties-common dirmngr
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
RUN add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/'

# Install additional software
# R stuff
RUN apt-get update && apt-get install -y \
    r-base=4.0* 

# For building the report
RUN apt-get update && apt-get install -y \
    xsltproc \
    libxml2-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    bibtex2html \
    subversion \
    libgit2-dev
RUN Rscript -e 'install.packages(c("knitr", "devtools"), repos="https://cran.rstudio.com/")'
RUN Rscript -e 'library(devtools); install_version("xml2", "1.2.2", repos="https://cran.rstudio.com/")'

# Tools used in the report
RUN apt-get update && apt-get install -y \
    texlive-full \
    fonttools \
    fontconfig \
    libxml2-utils

# Packages used in the report
RUN Rscript -e 'library(devtools); install_version("ggplot2", "3.3.2", repos="https://cran.rstudio.com/")'

# Package dependencies
# 'xml2' already installed
RUN Rscript -e 'library(devtools); install_version("extrafont", "0.17", repos="https://cran.rstudio.com/")'
RUN Rscript -e 'extrafont::font_import(prompt=FALSE)'
RUN apt-get install -y libfontconfig1-dev
RUN Rscript -e 'library(devtools); install_github("thomasp85/systemfonts")'
RUN Rscript -e 'library(devtools); install_version("devoid", "0.1.1", repos="https://cran.rstudio.com/")'
RUN Rscript -e 'library(devtools); install_version("hexView", "0.3-4", repos="https://cran.rstudio.com/")'

# Using COPY will update (invalidate cache) if the tar ball has been modified!
RUN mkdir -p /opt/R/dvir/version-0.3-0/
COPY dvir_0.3-0.tar.gz /tmp
RUN R CMD INSTALL --library=/opt/R/dvir/version-0.3-0 /tmp/dvir_0.3-0.tar.gz
# RUN Rscript -e 'devtools::install_github("pmur002/dvir@v0.3-0", lib="/opt/R/dvir/version-0.3-0")'
RUN mkdir -p /opt/R/dvir/version-0.3-1/
# COPY dvir_0.3-1.tar.gz /tmp/
# RUN R CMD INSTALL --library=/opt/R/dvir/version-0.3-1/ /tmp/dvir_0.3-1.tar.gz
RUN Rscript -e 'devtools::install_github("pmur002/dvir@v0.3-1", lib="/opt/R/dvir/version-0.3-1")'

# Enable ImageMagick ghostscript-based conversions
RUN awk '!/<policy domain="coder" rights="none" pattern="P/ { print }' /etc/ImageMagick-6/policy.xml > tmp.xml && mv tmp.xml /etc/ImageMagick-6/policy.xml

RUN apt-get install -y locales && locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8

ENV TERM dumb

# Create $HOME and directory in there for FontConfig files
RUN mkdir -p /home/user/fontconfig/conf.d
ENV HOME /home/user
