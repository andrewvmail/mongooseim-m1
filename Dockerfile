FROM ubuntu:22.04

ARG BRANCH=5.1.0

RUN apt-get update && apt-get install -y \
    bash \
    bash-completion \
    wget \
    git \
    make \
    gcc \
    g++ \
    vim \
    bash-completion \
    libc6-dev \
    libncurses5-dev \
    libssl-dev \
    libexpat1-dev \
    libpam0g-dev \
    unixodbc-dev \
    gnupg \
    zlib1g-dev \
    wget \
    curl

RUN apt install -y erlang

RUN git clone https://github.com/esl/MongooseIM --branch $BRANCH \
    && cd MongooseIM \
    && tools/configure with-all \
    && make rel \
    && make install \
    && cd _build/prod/rel \
    && tar cfzh mongooseim.tar.gz mongooseim

FROM ubuntu:22.04

COPY ./start.sh /start.sh
COPY --from=0 /MongooseIM/_build/prod/rel/mongooseim.tar.gz /usr/lib/

VOLUME ["/member", "/var/lib/mongooseim"]

RUN apt-get update && apt-get install -y \
        libssl-dev \
        iproute2 \
        netcat \
        inetutils-ping \
        telnet \
        unixodbc \
        tdsodbc \
        odbc-postgresql && \
        apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /usr/lib
RUN tar -xvf /usr/lib/mongooseim.tar.gz 
WORKDIR /

ENTRYPOINT ["/start.sh"]
 