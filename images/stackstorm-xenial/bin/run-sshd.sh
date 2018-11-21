#!/bin/bash
set -eux

# https://github.com/StackStorm/st2-packages/blob/master/scripts/st2bootstrap-deb.sh
# Copied from: https://github.com/StackStorm/st2-packages/blob/51b57213406e12715f82e49f11dbc614280304c3/scripts/st2bootstrap-deb.sh#L261-L298
configure_st2_user () {
  # Create an SSH system user (default `stanley` user may be already created)
  if (! id stanley 2>/dev/null); then
    sudo useradd stanley
  fi

  SYSTEM_HOME=$(echo ~stanley)

  sudo mkdir -p ${SYSTEM_HOME}/.ssh

  # Generate ssh keys on StackStorm box and copy over public key into remote box.
  # NOTE: If the file already exists and is non-empty, then assume the key does not need
  # to be generated again.
  if ! sudo test -s ${SYSTEM_HOME}/.ssh/stanley_rsa; then
    sudo ssh-keygen -f ${SYSTEM_HOME}/.ssh/stanley_rsa -P ""
  fi

  if ! sudo grep -s -q -f ${SYSTEM_HOME}/.ssh/stanley_rsa.pub ${SYSTEM_HOME}/.ssh/authorized_keys;
  then
    # Authorize key-base access
    sudo sh -c "cat ${SYSTEM_HOME}/.ssh/stanley_rsa.pub >> ${SYSTEM_HOME}/.ssh/authorized_keys"
  fi

  sudo chmod 0600 ${SYSTEM_HOME}/.ssh/authorized_keys
  sudo chmod 0700 ${SYSTEM_HOME}/.ssh
  sudo chown -R stanley:stanley ${SYSTEM_HOME}

  # Enable passwordless sudo
  local STANLEY_SUDOERS="stanley    ALL=(ALL)       NOPASSWD: SETENV: ALL"
  if ! sudo grep -s -q ^"${STANLEY_SUDOERS}" /etc/sudoers.d/st2; then
    sudo sh -c "echo '${STANLEY_SUDOERS}' >> /etc/sudoers.d/st2"
  fi

  sudo chmod 0440 /etc/sudoers.d/st2

  # Disable requiretty for all users
  sudo sed -i -r "s/^Defaults\s+\+?requiretty/# Defaults requiretty/g" /etc/sudoers
}


configure_st2_user

# Fix key permission
sudo chmod 0400 /home/stanley/.ssh/stanley_rsa

# Delete IPv6 entry from hosts file
TMP_HOSTS=$(mktemp)
sed -e '/^[0-9a-f:]*:/d' /etc/hosts > $TMP_HOSTS
cp $TMP_HOSTS /etc/hosts
rm $TMP_HOSTS

mkdir -p /var/run/sshd

exec /usr/sbin/sshd -D
