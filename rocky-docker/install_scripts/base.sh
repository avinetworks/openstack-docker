set -x
set -e

apt-get update
export DEBIAN_FRONTEND=noninteractive
apt-get --yes install software-properties-common
add-apt-repository -y cloud-archive:rocky
apt-get update && apt-get -y dist-upgrade
apt-get install -y python-openstackclient  python-pip git
apt-get install -y ssh-client

# Following packages needed for debugging
apt-get install -y net-tools vim
