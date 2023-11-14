# no apt to install jq, so we copy it over
FROM wesleydeanflexion/busybox-jq:14 AS jq

FROM cephalopodequipment/osmosisd:20.1.2

USER root

COPY --from=jq /bin/jq /bin/jq

WORKDIR /opt

COPY scripts/* /opt

ENTRYPOINT [ ]
CMD [ "/opt/run.sh" ]