FROM ghcr.io/osgeo/gdal:ubuntu-small-3.10.2
SHELL ["/bin/bash", "-c"]

# Installing dependencies efficiently
RUN apt-get update && apt-get install -y \
    wget \
    python3-pip \
    python3-venv \
    net-tools \
    traceroute

ENV VIRTUAL_ENV=/home/ubuntu/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Installing jupyter inside venv
RUN pip install jupyter

# Installing git
RUN apt-get update && apt-get install -y git

RUN apt-get install -y jq

ARG EDK_VERSION=mater
# Installing earth_data_kit from GitHub master branch
RUN git clone https://github.com/earth-data-kit/earth-data-kit.git /home/ubuntu/earth-data-kit
WORKDIR /home/ubuntu/earth-data-kit

RUN git fetch && git checkout release/v0.1.2
RUN source install-gdal.sh && install_gdal

WORKDIR /home/ubuntu/earth-data-kit
RUN source install-s5cmd.sh && install_s5cmd

RUN chmod +x ./install.sh
RUN ./install.sh

WORKDIR /

# Fixing permissions
ARG NB_USER=ubuntu
ARG NB_UID=1000
ENV USER=${NB_USER}
ENV NB_UID=${NB_UID}
ENV HOME=/home/${NB_USER}

# Make sure the contents of our repo are in ${HOME}
COPY ./notebooks ${HOME}/notebooks
USER root
RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}

# Setting working directory as /home/ubuntu/notebooks
WORKDIR ${HOME}/notebooks

CMD ["tail", "-f", "/dev/null"]