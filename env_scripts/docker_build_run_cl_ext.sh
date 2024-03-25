DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
cd $DIR

MY_UID=$(id -u)
MY_GID=$(id -g)
MY_UNAME=$(id -un)
mkdir -p ${DIR}/.vscode-server
# the following LINK is because we map $DIR/.. to /opt/NeMo-Aligner in the container
LINK=$(realpath --relative-to="${DIR}/.." "$DIR" -s)
TGT_CODE_FOLDER='/opt/NeMo-Aligner'
LINK="$TGT_CODE_FOLDER/$LINK"

# LINK=$(realpath --relative-to="/home/${MY_UNAME}" "$DIR" -s)
# BASE_IMAGE=nvcr.io/nvidia/nemo:24.01.gemma
# BASE_IMAGE=gitlab-master.nvidia.com:5005/dl/joc/nemo-aligner:20240105-nemo-1.22.0-mlm-0.4.0-TE-1.1
BASE_IMAGE=gitlab-master.nvidia.com:5005/dl/joc/nemo-ci/train:pipe.11084169
# BASE_IMAGE=gitlab-master.nvidia.com/dl/joc/nemo-ci/aligner:pipe.12368808
# BASE_IMAGE=nvcr.io/nvidia/nemo:24.01.framework
IMAGE=nemo_aligner_11084169
if [ -z "$(docker images -q ${IMAGE})" ]; then
    # Create dev.dockerfile
    FILE=dev.dockerfile

    ### Pick Tensorflow / Torch based base image below
    echo "FROM $BASE_IMAGE" > $FILE

    echo "  RUN apt-get update" >> $FILE
    echo "  RUN apt-get -y install nano gdb time" >> $FILE
    echo "  RUN apt-get -y install sudo" >> $FILE
    echo "  RUN (groupadd -g $MY_GID $MY_UNAME || true) && useradd --uid $MY_UID -g $MY_GID --no-log-init --create-home $MY_UNAME && (echo \"${MY_UNAME}:password\" | chpasswd) && (echo \"${MY_UNAME} ALL=(ALL) NOPASSWD: ALL\" >> /etc/sudoers)" >> $FILE

    echo "  RUN mkdir -p $DIR" >> $FILE
    echo "  RUN ln -s ${LINK}/.vscode-server /home/${MY_UNAME}/.vscode-server" >> $FILE
    echo "  RUN echo \"fs.inotify.max_user_watches=524288\" >> /etc/sysctl.conf" >> $FILE
    echo "  RUN sysctl -p" >> $FILE
    echo "  USER $MY_UNAME" >> $FILE

    # create convenient bashrc. do we need the first line ?
    echo "  COPY docker.bashrc /home/${MY_UNAME}/.bashrc" >> $FILE 

    # START: install any additional package required for your image here
    # END: install any additional package required for your image here
    echo "  RUN source /home/${MY_UNAME}/.bashrc" >> $FILE
    echo "  WORKDIR $TGT_CODE_FOLDER" >> $FILE
    echo "  CMD /bin/bash" >> $FILE

    docker buildx build -f dev.dockerfile -t ${IMAGE} .
fi

# mount the scratch folders : assuming you have a relative soft link to scratch created by  'ln -s ../scratch.gkoren_gpu scratch'
EXTRA_MOUNTS=""
if [ -d "/home/${MY_UNAME}/scratch" ]; then
    EXTRA_MOUNTS+=" --mount type=bind,source=/home/${MY_UNAME}/scratch,target=/home/${MY_UNAME}/scratch"
fi
# if you have another scratch : 
if [ -d "/home/${MY_UNAME}/scratch_1" ]; then
    EXTRA_MOUNTS+=" --mount type=bind,source=/home/${MY_UNAME}/scratch_1,target=/home/${MY_UNAME}/scratch_1"
fi


docker run \
    --gpus \"device=${NVIDIA_VISIBLE_DEVICES:-0}\" \
    --privileged -p 5567:5567 \
    --ipc=host --ulimit memlock=-1 --ulimit stack=67108864 -it --rm \
    --mount type=bind,source=${DIR}/..,target=${TGT_CODE_FOLDER} \
    ${EXTRA_MOUNTS} \
    ${IMAGE}

    # --mount type=bind,source=/home/scratch.svc_compute_arch,target=/home/scratch.svc_compute_arch \
    # --mount type=bind,source=/home/utils,target=/home/utils \
    # --mount type=bind,source=/home/scratch.computelab,target=/home/scratch.computelab \
    #     -p 8888:8888 -p 6006:6006\
    # --mount type=bind,source=${DIR}/..,target=${DIR}/.. \

cd -