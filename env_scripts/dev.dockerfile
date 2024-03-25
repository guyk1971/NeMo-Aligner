FROM gitlab-master.nvidia.com:5005/dl/joc/nemo-ci/train:pipe.11084169
  RUN apt-get update
  RUN apt-get -y install nano gdb time
  RUN apt-get -y install sudo
  RUN (groupadd -g 30 gkoren || true) && useradd --uid 90013 -g 30 --no-log-init --create-home gkoren && (echo "gkoren:password" | chpasswd) && (echo "gkoren ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers)
  RUN mkdir -p /home/gkoren/code/github/clones/NeMo-Aligner/env_scripts
  RUN ln -s /opt/NeMo-Aligner/env_scripts/.vscode-server /home/gkoren/.vscode-server
  RUN echo "fs.inotify.max_user_watches=524288" >> /etc/sysctl.conf
  RUN sysctl -p
  USER gkoren
  COPY docker.bashrc /home/gkoren/.bashrc
  RUN source /home/gkoren/.bashrc
  WORKDIR /opt/NeMo-Aligner
  CMD /bin/bash
