# mccahill/shiny
#
# VERSION               0.10

FROM   ubuntu:14.04
MAINTAINER Mark McCahill "mark.mccahill@duke.edu"

# get R from a CRAN archive 
RUN echo "deb http://cran.rstudio.com/bin/linux/ubuntu trusty/"  >> /etc/apt/sources.list
RUN DEBIAN_FRONTEND=noninteractive apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9

RUN apt-get update && \
    apt-get upgrade -y

# we want OpenBLAS for faster linear algebra as described here: http://brettklamer.com/diversions/statistical/faster-blas-in-r/
RUN apt-get install -y \
   libopenblas-base
RUN apt-get update

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes \
   r-base \
   r-base-dev

#Utilities
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
   vim \
   less \
   net-tools \
   inetutils-ping \
   curl \
   git \
   telnet \
   nmap \
   socat \
   python-software-properties \
   wget \
   sudo \
   libcurl4-openssl-dev  \
   libxml2-dev

RUN apt-get update && \
    apt-get upgrade -y

# we need TeX for the rmarkdown package in RStudio

# TeX 
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
   texlive \ 
   texlive-base \ 
   texlive-latex-extra \ 
   texlive-pstricks 

# R-Studio
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
   gdebi-core \
   libapparmor1
RUN DEBIAN_FRONTEND=noninteractive wget https://download2.rstudio.org/rstudio-server-0.99.902-amd64.deb
RUN DEBIAN_FRONTEND=noninteractive gdebi -n rstudio-server-0.99.902-amd64.deb
RUN rm rstudio-server-0.99.902-amd64.deb


# R packages we need for devtools - and we need devtools to be able to update the rmarkdown package
RUN DEBIAN_FRONTEND=noninteractive wget \
   http://mirrors.nics.utk.edu/cran/src/contrib/rstudioapi_0.6.tar.gz \
   http://mirrors.nics.utk.edu/cran/src/contrib/openssl_0.9.4.tar.gz \
   http://mirrors.nics.utk.edu/cran/src/contrib/withr_1.0.2.tar.gz \
   http://mirrors.nics.utk.edu/cran/src/contrib/brew_1.0-6.tar.gz \
   http://mirrors.nics.utk.edu/cran/src/contrib/stringi_1.1.1.tar.gz \
   http://mirrors.nics.utk.edu/cran/src/contrib/magrittr_1.5.tar.gz \
   http://mirrors.nics.utk.edu/cran/src/contrib/stringr_1.0.0.tar.gz \
   http://mirrors.nics.utk.edu/cran/src/contrib/roxygen2_5.0.1.tar.gz \
   http://mirrors.nics.utk.edu/cran/src/contrib/rversions_1.0.2.tar.gz \
   http://mirrors.nics.utk.edu/cran/src/contrib/git2r_0.15.0.tar.gz \
   http://mirrors.nics.utk.edu/cran/src/contrib/devtools_1.12.0.tar.gz \
   http://mirrors.nics.utk.edu/cran/src/contrib/R6_2.1.2.tar.gz \
   http://mirrors.nics.utk.edu/cran/src/contrib/mime_0.4.tar.gz \
   http://mirrors.nics.utk.edu/cran/src/contrib/httr_1.2.0.tar.gz \
   http://mirrors.nics.utk.edu/cran/src/contrib/bitops_1.0-6.tar.gz \
   http://mirrors.nics.utk.edu/cran/src/contrib/RCurl_1.95-4.8.tar.gz \
   http://mirrors.nics.utk.edu/cran/src/contrib/BH_1.60.0-2.tar.gz \
   http://mirrors.nics.utk.edu/cran/src/contrib/xml2_1.0.0.tar.gz \
   http://mirrors.nics.utk.edu/cran/src/contrib/curl_0.9.7.tar.gz \
   http://mirrors.nics.utk.edu/cran/src/contrib/jsonlite_0.9.22.tar.gz \
   http://mirrors.nics.utk.edu/cran/src/contrib/downloader_0.4.tar.gz \
   http://mirrors.nics.utk.edu/cran/src/contrib/digest_0.6.9.tar.gz \
   http://mirrors.nics.utk.edu/cran/src/contrib/memoise_1.0.0.tar.gz \
   http://mirrors.nics.utk.edu/cran/src/contrib/Rcpp_0.12.5.tar.gz \
   http://mirrors.nics.utk.edu/cran/src/contrib/plyr_1.8.4.tar.gz \
   http://mirrors.nics.utk.edu/cran/src/contrib/XML_3.98-1.4.tar.gz \
   http://mirrors.nics.utk.edu/cran/src/contrib/whisker_0.3-2.tar.gz

RUN DEBIAN_FRONTEND=noninteractive R CMD INSTALL \
   jsonlite_0.9.22.tar.gz \
   digest_0.6.9.tar.gz \
   memoise_1.0.0.tar.gz \
   whisker_0.3-2.tar.gz \
   bitops_1.0-6.tar.gz \
   RCurl_1.95-4.8.tar.gz \
   Rcpp_0.12.5.tar.gz \
   plyr_1.8.4.tar.gz \
   R6_2.1.2.tar.gz \
   curl_0.9.7.tar.gz \
   openssl_0.9.4.tar.gz \
   mime_0.4.tar.gz \
   httr_1.2.0.tar.gz \
   rstudioapi_0.6.tar.gz \
   withr_1.0.2.tar.gz \
   brew_1.0-6.tar.gz \
   stringi_1.1.1.tar.gz \
   magrittr_1.5.tar.gz \
   stringr_1.0.0.tar.gz \
   roxygen2_5.0.1.tar.gz \
   XML_3.98-1.4.tar.gz \
   BH_1.60.0-2.tar.gz \
   xml2_1.0.0.tar.gz \
   rversions_1.0.2.tar.gz \
   git2r_0.15.0.tar.gz \
   devtools_1.12.0.tar.gz \
   downloader_0.4.tar.gz

RUN rm \
   jsonlite_0.9.22.tar.gz \
   digest_0.6.9.tar.gz \
   memoise_1.0.0.tar.gz \
   whisker_0.3-2.tar.gz \
   bitops_1.0-6.tar.gz \
   RCurl_1.95-4.8.tar.gz \
   Rcpp_0.12.5.tar.gz \
   plyr_1.8.4.tar.gz \
   R6_2.1.2.tar.gz \
   mime_0.4.tar.gz \
   httr_1.2.0.tar.gz \
   rstudioapi_0.6.tar.gz \
   openssl_0.9.4.tar.gz \
   withr_1.0.2.tar.gz \
   brew_1.0-6.tar.gz \
   stringi_1.1.1.tar.gz \
   magrittr_1.5.tar.gz \
   stringr_1.0.0.tar.gz \
   roxygen2_5.0.1.tar.gz \
   XML_3.98-1.4.tar.gz \
   BH_1.60.0-2.tar.gz \
   xml2_1.0.0.tar.gz \
   curl_0.9.7.tar.gz \
   rversions_1.0.2.tar.gz \
   git2r_0.15.0.tar.gz \
   devtools_1.12.0.tar.gz \
   downloader_0.4.tar.gz




# Supervisord
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y supervisor && \
   mkdir -p /var/log/supervisor
CMD ["/usr/bin/supervisord", "-n"]

ADD ./conf /additional-configs
RUN cp /additional-configs/supervisord-shiny.conf /etc/supervisor/conf.d/supervisord-shiny.conf

# Shiny
RUN R CMD BATCH /additional-configs/install-Shiny.R

# add a non-root user so we can log into R studio as that user; make sure that user is in the group "users"
RUN adduser --disabled-password --gecos "" --ingroup users guest 

# VerificationMeasures package and dependencies
RUN DEBIAN_FRONTEND=noninteractive wget http://mirrors.nics.utk.edu/cran/src/contrib/smoothmest_0.1-2.tar.gz
RUN DEBIAN_FRONTEND=noninteractive R CMD INSTALL smoothmest_0.1-2.tar.gz
RUN rm smoothmest_0.1-2.tar.gz

RUN cd /additional-configs ; R CMD INSTALL VerificationMeasures_0.1.tar.gz

# add a script that supervisord uses to set the user's password based on an optional
# environmental variable ($VNCPASS) passed in when the containers is instantiated
ADD initialize.sh /

# set the locale so RStudio doesn't complain about UTF-8
RUN locale-gen en_US en_US.UTF-8
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales


#########
#
# if you need additional tools/libraries, add them here.
# also, note that we use supervisord to launch both the password
# initialize script and the RStudio server. If you want to run other processes
# add these to the supervisord.conf file
#
#########

EXPOSE 8787 

CMD ["/usr/bin/supervisord"]

