FROM busybox

WORKDIR /app
COPY ./waitbox.sh ./waitbox.sh
RUN chmod +x ./waitbox.sh

RUN ln -s /app/waitbox.sh /usr/bin/waitbox

ENTRYPOINT [ "waitbox" ]
