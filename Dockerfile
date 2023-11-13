# BaseImage (OS)
FROM pytorch/pytorch:2.0.0-cuda11.7-cudnn8-devel

LABEL maintrainer="namkuk.kim@saltlux.com"
LABEL name="CodeLlama-2 fine-tuning dev environment"
LABEL version="v1.0.0"

####################################################
# OS Setting
####################################################
# Remove any third-party apt sources to avoid issues with expiring keys.
RUN rm -f /etc/apt/sources.list.d/*.list

# Install some basic utilities & python prerequisites
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && apt-get install -y --no-install-recommends\
    vim \
    curl \
    net-tools \
    apt-utils \
    ssh \
    tree \
    ca-certificates \
    sudo \
    git \
    bzip2 \
    libx11-6 \
    make \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    wget \
    llvm \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev \
    python3-openssl && \
    rm -rf /var/lib/apt/lists/*

# Set up time zone
ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime

####################################################
# SSH Setting
####################################################
# Add config for ssh connection
RUN echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "PermitEmptyPasswords yes" >> /etc/ssh/sshd_config

# Re-run ssh when the container restarts.
RUN echo "sudo service ssh start > /dev/null" >> $HOME/.bashrc

####################################################
# Workspace Setting
####################################################
# Create a workspace directory
WORKDIR /workspace

####################################################
# Python Setting
####################################################
RUN echo "accelerate \n\
appdirs \n\
bitsandbytes \n\
datasets \n\
fire \n\
git+https://github.com/huggingface/peft.git  \n\
git+https://github.com/huggingface/transformers.git  \n\
torch \n\
sentencepiece \n\
tensorboardX \n\
gradio \n\
cmake \n\
lit \n\
scipy \n\
seaborn" > requirements.txt
RUN pip install pip --upgrade \
    && pip install -r requirements.txt

# Install Poetry
ENV PATH "~/.local/bin:$PATH"
ENV PYTHON_KEYRING_BACKEND keyring.backends.null.Keyring
RUN curl -sSL https://install.python-poetry.org | python -

# Install Jupyter lab
RUN pip install jupyterlab
