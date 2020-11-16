FROM ubuntu:18.04
MAINTAINER 4ct10n

# ARGS FROM Docker-compose.yml
ARG JDK
ARG JDKPATH
ARG WEBLOGICJAR

# Install Java

RUN mkdir -p /opt/jdk
ADD jdk_use/$JDK /opt/jdk/
ENV JAVA_HOME /opt/jdk/$JDKPATH
ENV PATH $PATH:$JAVA_HOME/bin
ENV WEBLOGICJAR $WEBLOGICJAR
# Create User
RUN groupadd -g 1000 oinstall && useradd -u 1100 -g oinstall oracle

# Create Directory and add ENV

RUN mkdir -p /weblogic/scripts && \
    mkdir -p /weblogic/install && \
    mkdir -p /weblogic/software && \
    mkdir -p /weblogic/oracle/middleware && \
    mkdir -p /weblogic/oracle/config/domains && \
    mkdir -p /weblogic/oracle/config/applications && \
    mkdir -p /weblogic/oracle/properties && \
    chown -R oracle:oinstall /weblogic && \
    chmod -R 775 /weblogic/

ENV MW_HOME=/weblogic/oracle/middleware
ENV WLS_HOME=$MW_HOME/wlserver
ENV WL_HOME=$WLS_HOME
ENV ORACLE_HOME=/weblogic/oracle
ENV CREATEDOMAIN=/weblogic/scripts/CreateDomain
ENV WEBLOGICINSTALL=/weblogic/scripts/WeblogicInstall
# Copy files
COPY weblogic_use/$WEBLOGICJAR /weblogic/install
COPY /scripts /weblogic/scripts/

# Choose version scripts and give exec privilege
RUN chmod -R +x  /weblogic/scripts/

RUN /weblogic/scripts/Debug/choose_script.sh
# Begin install
RUN /weblogic/scripts/WeblogicInstall/weblogic_install.sh
RUN /weblogic/scripts/CreateDomain/create_domain.sh
RUN /weblogic/scripts/Debug/open_debug_mode.sh

CMD ["/weblogic/scripts/StartUp/startWebLogic.sh"]
EXPOSE 7001