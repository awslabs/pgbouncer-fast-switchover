FROM public.ecr.aws/amazonlinux/amazonlinux:2022

RUN yum -y update
RUN yum install -y tar net-tools curl vim unzip less libevent-devel openssl-devel python-devel libtool git patch make gcc wget --allowerasing
# Install pandoc
RUN wget https://github.com/jgm/pandoc/releases/download/3.1.6.2/pandoc-3.1.6.2-linux-amd64.tar.gz && \
    tar xvzf ./pandoc-3.1.6.2-linux-amd64.tar.gz --strip-components 1 -C /usr/local
RUN git clone https://github.com/pgbouncer/pgbouncer.git --branch "stable-1.19" && \
    git clone https://github.com/awslabs/pgbouncer-rr-patch.git && \
    cd pgbouncer-rr-patch && \
    ./install-pgbouncer-rr-patch.sh ../pgbouncer && \
    cd ../pgbouncer && \
    git submodule init && \
    git submodule update && \
    ./autogen.sh && \
    ln -s /usr/bin/x86_64-amazon-linux-gnu-pkg-config /usr/bin/x86_64-redhat-linux-gnu-pkg-config && \
    ./configure --prefix=/usr/local --exec-prefix=/usr/bin && \
    make && \
    make install

RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
RUN chmod +x ./kubectl && \
    mv kubectl /usr/sbin
RUN chmod 777 -R /usr/local/

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
RUN mkdir /home/pgbouncer/.aws
COPY config /home/pgbouncer/.aws


#COPY config /home/pgbouncer/.aws
COPY ./start.sh /start.sh
COPY ./pub_metrics.sh /pub_metrics.sh
COPY ./adaptivepgbouncer.sh /adaptivepgbouncer.sh

COPY ./routing_rules.py /home/pgbouncer/

ENTRYPOINT ["/bin/bash", "/start.sh"]
