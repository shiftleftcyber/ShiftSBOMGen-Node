FROM node:22-alpine3.20

ARG ARCH

# hadolint ignore=DL3018
RUN apk update \
    && apk upgrade \
    && apk --no-cache add bash

SHELL ["/bin/bash", "-c"]

ENV CYCLONEDX_NPM_VERSION="1.19.3" \
    GEN_SBOM_SCRIPT_LOCATION="/opt"
ENV PATH="${GEN_SBOM_SCRIPT_LOCATION}:${PATH}"

COPY gen_*.sh $GEN_SBOM_SCRIPT_LOCATION/

# install dependencies
RUN npm install --global @cyclonedx/cyclonedx-npm@${CYCLONEDX_NPM_VERSION} \
  && rm -rf /root/.npm

# Create a non-root user and group
RUN addgroup --system --gid 1002 bitbucket-group && \
  adduser --system --uid 1002 --ingroup bitbucket-group bitbucket-user

USER bitbucket-user

WORKDIR /build
ENTRYPOINT ["gen_sbom.sh"]
