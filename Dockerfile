FROM renatbek/play:cached
MAINTAINER Renat Bekbolatov <renatbek@gmail.com>

COPY ./ /app/.

RUN mkdir -p /var/lib/starpractice/activity
COPY activity /var/lib/starpractice/activity/.

EXPOSE 9000 
WORKDIR /app
#CMD ["activator", "run"]

