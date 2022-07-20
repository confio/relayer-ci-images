FROM cephalopodequipment/gaiad:7.0.1-rocks

USER root

RUN apt install -y jq

WORKDIR /opt

COPY scripts/* /opt

CMD [ "/opt/run.sh" ]