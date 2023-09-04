FROM public.ecr.aws/amazonlinux/amazonlinux:2022
ARG AWSCLIARCH
ENV AWSCLIARCH=$AWSCLIARCH
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

# Install kubectl for the simulator pod scaler
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/"$ARCH"/kubectl"
RUN chmod +x ./kubectl && \
    mv kubectl /usr/sbin
RUN chmod 777 -R /usr/local/
RUN kubectl version --client

# Install psql
#RUN yum list | grep postgresql
RUN yum install -y postgresql15-server postgresql15-contrib
RUN psql --version

# Installed with pgbouncer
RUN useradd -ms /bin/bash pgbouncer && \
    chown pgbouncer /home/pgbouncer && \
    chown pgbouncer /

USER pgbouncer
WORKDIR /home/pgbouncer

#Install aws cli
RUN cd /home/pgbouncer
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install
RUN /usr/local/bin/aws --version
RUN mkdir /home/pgbouncer/.aws
COPY config /home/pgbouncer/.aws
