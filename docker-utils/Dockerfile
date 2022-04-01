FROM ubuntu:impish

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

RUN apt-get update && apt-get install -y git build-essential pkg-config autoconf automake libtool texinfo guile-3.0 guile-3.0-dev golang-go

USER user
WORKDIR /home/user/
RUN mkdir /home/user/bin/

# make and install guile-rpc:

RUN git clone git://git.sv.gnu.org/guile-rpc.git
WORKDIR /home/user/guile-rpc/
RUN mkdir m4
RUN cp /usr/share/aclocal/guile.m4 m4/
RUN autoreconf -vfi
RUN ./configure --prefix=/home/user
RUN make install
WORKDIR /home/user/

# install stc
ENV PATH=/home/user/go/bin:${PATH}
RUN GOPROXY=direct go install github.com/xdrpp/stc/...@latest
# install script xdr_spec_to-sexp.sh:

ENV PATH=/home/user/bin:${PATH}
RUN grpc-compile --help # force compilation
COPY --chown=user:user xdr_spec_to_sexp.sh /home/user/bin/
RUN chmod +x /home/user/bin/xdr_spec_to_sexp.sh

# install script serialize.sh:

RUN git clone  https://github.com/jacobrec/guile-lib.git jlib # for base64 support
COPY --chown=user:user serialize.scm /home/user/
RUN guile serialize.scm # force compilation
COPY --chown=user:user Stellar.x /home/user/
COPY --chown=user:user serialize.sh /home/user/bin/
RUN chmod +x /home/user/bin/serialize.sh

