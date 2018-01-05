
SSHDIR=./ssh
PRIVATE_KEYFILE=${SSHDIR}/id_rsa
PUBLIC_KEYFILE=${SSHDIR}/id_rsa.pub

mkdir -p $SSHDIR

if [ ! -f $PRIVATE_KEYFILE ]; then
	ssh-keygen -b 2048 -t rsa -f $PRIVATE_KEYFILE -q -N ""
fi

chmod 400 ${SSHDIR}/*
