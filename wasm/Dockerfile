# no apt to install jq, so we copy it over
FROM cosmwasm/wasmd:0.27.0

USER root

RUN apt install -y jq

WORKDIR /opt

COPY scripts/* /opt

CMD [ "/opt/run.sh" ]