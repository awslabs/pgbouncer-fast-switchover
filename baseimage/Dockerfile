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

# Installed with pgbouncer
RUN useradd -ms /bin/bash pgbouncer && \
    chown pgbouncer /home/pgbouncer && \
    chown pgbouncer /

USER pgbouncer
WORKDIR /home/pgbouncer

#Install aws cli
RUN cd /home/pgbouncer
#RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-"$AWSCLIARCH".zip" -o "awscliv2.zip"
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN pwd
RUN ls -l aws
#RUN ./aws/install
#RUN mkdir /home/pgbouncer/.aws
#COPY config /home/pgbouncer/.aws

#Install kubectl for the simulator pod scaler
RUN curl -O "https://s3.us-west-2.amazonaws.com/amazon-eks/1.27.4/2023-08-16/bin/linux/"$ARCH"/kubectl"
RUN chmod +x ./kubectl
RUN mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH
RUN echo 'export PATH=$HOME/bin:$PATH' >> /home/pgbouncer/.bashrc
RUN kubectl version --short --client
