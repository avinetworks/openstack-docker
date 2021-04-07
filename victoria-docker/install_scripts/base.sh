set -x
set -e

apt-get --yes update
export DEBIAN_FRONTEND=noninteractive
apt-get install -y --no-install-recommends apt-utils
apt-get --yes install software-properties-common
add-apt-repository -y cloud-archive:victoria
apt-get -y update && apt-get -y upgrade && apt-get -y dist-upgrade
apt-get install -y python3-openstackclient  python3-pip git
apt-get install -y ssh-client

# Following packages needed for debugging
apt-get install -y net-tools vim
