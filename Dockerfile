FROM python:3.6.4-alpine

COPY azu-tartifact.pem /usr/local/share/ca-certificates

RUN apk update \
        && apk add --no-cache bash \
                              curl \
                              coreutils \
                              openssl \
        && apk add --virtual=build \
                             gcc \
                             make \
                             ca-certificates \
                             libffi-dev \
                             musl-dev \
                             libxml2-dev \
                             libxslt-dev \
                             linux-headers \
                             gcc \
                             libffi \
                             openssl-dev \
                             python-dev \
        && (update-ca-certificates 2>/dev/null || true) \
        && pip install azure-cli \
        && apk del --purge build

RUN wget https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_linux_amd64.zip \
 && unzip terraform_0.11.7_linux_amd64.zip -d /usr/local/bin/ && rm terraform_0.11.7_linux_amd64.zip

#installing Java 8
RUN apk add openjdk8 \
  && rm -rf /var/cache/apk/*

# installing Flyway
RUN wget https://azu-tartifact.corp.footlocker.net:443/artifactory/fl-dataplatform-maven-central/org/flywaydb/flyway-commandline/5.0.7/flyway-commandline-5.0.7-linux-x64.tar.gz \
 && tar -xzf flyway-commandline-5.0.7-linux-x64.tar.gz  \
 && rm flyway-commandline-5.0.7-linux-x64.tar.gz \
 && rm /flyway-5.0.7/jre/bin/java \
 && echo -ne "- with Flyway $FLYWAY_VERSION\n" >> /root/.built
 
