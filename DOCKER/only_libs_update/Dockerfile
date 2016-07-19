FROM renatbek/activator:1.3.10
MAINTAINER Renat Bekbolatov <renatbek@gmail.com>

RUN mkdir /deployment

COPY target/lib /deployment/lib

COPY entrypoint.sh /deployment/
RUN chmod a+x /deployment/entrypoint.sh

ENTRYPOINT ["/deployment/entrypoint.sh"]

CMD ["echo", "library update is done"]
