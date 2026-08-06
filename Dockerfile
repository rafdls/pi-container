FROM node:22-bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    fd-find \
    git \
    jq \
    less \
    openssh-client \
    ripgrep \
    vim \
    zsh \
  && rm -rf /var/lib/apt/lists/*

# Install Pi coding agent.
RUN npm install -g @earendil-works/pi-coding-agent@0.83.0

# Create a non-root user.
RUN useradd -m -s /bin/bash piagent

# Add common Git hosts to known_hosts so SSH git works without prompting.
RUN mkdir -p /home/piagent/.ssh \
  && ssh-keyscan github.com gitlab.com bitbucket.org >> /home/piagent/.ssh/known_hosts \
  && chown -R piagent:piagent /home/piagent/.ssh \
  && chmod 700 /home/piagent/.ssh \
  && chmod 644 /home/piagent/.ssh/known_hosts

USER piagent

RUN mkdir -p /home/piagent/.pi/agent

WORKDIR /workspace

CMD ["/bin/bash"]
