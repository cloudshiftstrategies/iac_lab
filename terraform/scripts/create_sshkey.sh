#!/bin/bash
# create_sshkey.sh - creates an ssh keypair in terrafrom/ssh/ dir

SSHDIR=../ssh
PRIVATE_KEYFILE=${SSHDIR}/id_rsa
PUBLIC_KEYFILE=${SSHDIR}/id_rsa.pub

mkdir -p $SSHDIR

if [ ! -f $PRIVATE_KEYFILE ]; then
	echo "Creating private key file ${PRIVATE_KEYFILE}"
	ssh-keygen -b 2048 -t rsa -f $PRIVATE_KEYFILE -q -N ""
else
	echo "Private Key file ${PRIVATE_KEYFILE} already exists. Existing"
fi

chmod 400 ${SSHDIR}/*
