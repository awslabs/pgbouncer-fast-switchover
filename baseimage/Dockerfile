FROM public.ecr.aws/amazonlinux/amazonlinux:2022
ARG PANDOC_VER
ENV PANDOC_VER=$PANDOC_VER
ARG ARCH
ENV ARCH=$ARCH
ENV PANDOC_PKG="pandoc-"$PANDOC_VER"-linux-"$ARCH".tar.gz"
ENV PANDOC_URL="https://github.com/jgm/pandoc/releases/download/"$PANDOC_VER"/"$PANDOC_PKG

RUN yum -y update
RUN yum install -y tar net-tools curl vim unzip less libevent-devel openssl-devel python-devel libtool git patch make gcc wget --allowerasing

# Install pandoc
RUN wget $PANDOC_URL && \
    tar xvzf ./$PANDOC_PKG --strip-components 1 -C /usr/local

# Installed with pgbouncer
RUN useradd -ms /bin/bash pgbouncer && \
    chown pgbouncer /home/pgbouncer && \
    chown pgbouncer /

USER pgbouncer
WORKDIR /home/pgbouncer

#Install aws cli
RUN pip install awscli
RUN mkdir /home/pgbouncer/.aws
COPY config /home/pgbouncer/.aws

#Install kubectl for the simulator pod scaler
RUN apt-get install -y apt-transport-https ca-certificates
RUN curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://dl.k8s.io/apt/doc/apt-key.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
RUN apt-get update
RUN apt-get install -y kubectl
