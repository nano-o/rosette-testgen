FROM ubuntu:focal

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils dialog ca-certificates

# Install and configure locale `en_US.UTF-8`
RUN apt-get update && apt-get install -y locales && \
    sed -i -e "s/# $en_US.*/en_US.UTF-8 UTF-8/" /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV TZ="America/Los_Angeles"

RUN apt-get update && apt-get install -y sudo rsync
# create a user:
RUN useradd -ms /bin/bash user && echo 'user:user' | chpasswd && adduser user sudo
RUN echo "ALL ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN apt-get update && apt-get install -y git
RUN apt-get update && apt-get install -y guile-3.0 guile-3.0-dev
RUN apt-get update && apt-get install -y build-essential pkg-config autoconf automake libtool texinfo

USER user
WORKDIR /home/user/
RUN git clone git://git.sv.gnu.org/guile-rpc.git
WORKDIR /home/user/guile-rpc/
RUN mkdir m4
RUN cp /usr/share/aclocal/guile.m4 m4/
RUN autoreconf -vfi
RUN ./configure --prefix=/home/user
RUN make install
WORKDIR /home/user/
ENV PATH=/home/user/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN grpc-compile --help # force compilation
COPY serialize.scm /home/user/
RUN guile serialize.scm # force compilation

# CMD grpc-compile --intermediate -S
# run with `cat spec.xdr | docker run -i --rm CONTAINER-ID
