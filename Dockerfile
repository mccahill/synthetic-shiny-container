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
   libcurl4-openssl-dev 

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

# Supervisord
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y supervisor && \
   mkdir -p /var/log/supervisor
CMD ["/usr/bin/supervisord", "-n"]

ADD ./conf /additional-configs
RUN cp /additional-configs/supervisord-shiny.conf /etc/supervisor/conf.d/supervisord-shiny.conf


# add a non-root user so we can log into R studio as that user; make sure that user is in the group "users"
RUN adduser --disabled-password --gecos "" --ingroup users guest 

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

