FROM atrkulja/x86_64-on-arm64

# install dependencies
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl

# setup steam user
RUN useradd -m steam
WORKDIR /home/steam
USER steam

COPY entrypoint.sh .

# install valheim server using steamcmd
ENV VALHEIM_SERVER_PASSWORD=password \
    VALHEIM_SERVER_NAME="My Valheim Server powered by Docker" \
    VALHEIM_SERVER_WORLD="Dedicated" \
    VALHEIM_SERVER_PUBLIC=0

# download steamcmd
RUN mkdir steamcmd && cd steamcmd && \
    curl "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -

# start steamcmd to force it to update itself
RUN ./steamcmd/steamcmd.sh +quit && \
    mkdir -pv /home/steam/.steam/sdk32/ && \
    ln -s /home/steam/steamcmd/linux32/steamclient.so /home/steam/.steam/sdk32/steamclient.so

VOLUME ["/home/steam/valheim/data"]

# start the server main script
ENTRYPOINT ["bash", "/home/steam/entrypoint.sh"]
EXPOSE 2456-2458/tcp
EXPOSE 2456-2458/udp