FROM renatbek/activator:1.3.10
MAINTAINER Renat Bekbolatov <renatbek@gmail.com>

RUN mkdir /deployment
RUN mkdir /deployment/lib
RUN mkdir /deployment/logs

COPY target/bin /deployment/bin
COPY target/conf /deployment/conf
COPY target/lib/sparkydots-server* /deployment/lib/

COPY entrypoint.sh /deployment/
RUN chmod a+x /deployment/entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["/deployment/entrypoint.sh"]

CMD ["/deployment/bin/sparkydots-server"]
