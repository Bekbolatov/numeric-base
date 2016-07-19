FROM renatbek/activator:1.3.10
MAINTAINER Renat Bekbolatov <renatbek@gmail.com>

RUN mkdir /deployment
COPY target/universal/sparkydots-server-1.0-SNAPSHOT.zip /deployment
RUN unzip /deployment/sparkydots-server-1.0-SNAPSHOT.zip -d /deployment/
RUN rm /deployment/sparkydots-server-1.0-SNAPSHOT.zip

RUN mkdir /logs
RUN mkdir /deployment/logs
EXPOSE 9000
CMD ["/deployment/sparkydots-server-1.0-SNAPSHOT/bin/sparkydots-server"]
