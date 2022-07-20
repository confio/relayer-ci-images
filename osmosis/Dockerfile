# no apt to install jq, so we copy it over
FROM wesleydeanflexion/busybox-jq:14 AS jq

FROM cephalopodequipment/osmosisd:9.0.0

USER root

COPY --from=jq /bin/jq /bin/jq

WORKDIR /opt

COPY scripts/* /opt

CMD [ "/opt/run.sh" ]