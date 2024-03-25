DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
cd $DIR
echo $DIR
MY_UID=$(id -u)
MY_GID=$(id -g)
MY_UNAME=$(id -un)
# LINK=$(realpath --relative-to="/home/${MY_UNAME}" "$DIR" -s)
LINK=$(realpath --relative-to="${DIR}/.." "$DIR" -s)
BASE_LINK='/opt/NeMo-Aligner'
LINK="$BASE_LINK/$LINK"


echo $LINK