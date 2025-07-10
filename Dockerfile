FROM ubuntu:24.04
LABEL maintainer="Andy McCall"
LABEL description="x86_64 Assembly development environment"
RUN apt-get update && apt-get install -y \
    build-essential \
    gdb \
    nasm \
    git \
    wget \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Remove the default ubuntu user and group, then create your user
ARG USERNAME=andymccall
ARG USER_UID=1000
ARG USER_GID=1000

RUN touch /var/mail/ubuntu && chown ubuntu:ubuntu /var/mail/ubuntu || true \
    && userdel -r ubuntu \
    && groupdel ubuntu 2>/dev/null || true \
    && groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Switch to your user
USER $USERNAME

# Install oh-my-bash for the user
RUN bash -c "$(wget https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh -O -)" && sed -i 's/OSH_THEME="font"/OSH_THEME="powerline-icon"/' ~/.bashrc

# Set working directory
WORKDIR /home/$USERNAME/development