FROM renatbek/play:cached
MAINTAINER Renat Bekbolatov <renatbek@gmail.com>

COPY ./ /app/.

RUN mkdir -p /var/lib/starpractice/activity
COPY activity /var/lib/starpractice/activity/.

EXPOSE 9000 
WORKDIR /app
RUN activator dist

RUN mkdir /deployment
RUN unzip target/universal/sparkydots-server-1.0-SNAPSHOT.zip -d /deployment/

CMD ["/deployment/sparkydots-server-1.0-SNAPSHOT/bin/sparkydots-server"]

