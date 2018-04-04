#!/bin/bash

# check if the docker image is build and exists
DOCKERIMAGE=myjsonld
EXISTSIMAGE=`sudo docker images ${DOCKERIMAGE} |grep ${DOCKERIMAGE}`

if [ -z "${EXISTSIMAGE}" ] ; then
    echo "docker image ${DOCKERIMAGE} not available. Please built it first."
    exit
fi


# docker image exists

FILE=$1
DIR=/tmp/jsonldconvertor/rdf
FILEFORMAT=nt
ARGS=$@

# check if the first argument is a file and exists
if [ -z "${FILE}" ] ; then
    echo "Mandatory file reference is missing." 
    exit
fi
if [ ! -f "${FILE}" ] ; then
    echo "file reference is not a valid file." 
    exit
fi

mkdir -p ${DIR}

if [ -f $FILE ] ; then 
   cp $FILE $DIR
   FILENAME=`namei $FILE | grep - |sed 's/ - //g' `
fi

sudo docker run -it --rm  --name myjsonld0 -v ${DIR}:/data/rdf  $DOCKERIMAGE ./jsonld2rdf.rb  -o /data/rdf $ARGS -f /data/rdf/$FILENAME 
#-O $FILEFORMAT

cat ${DIR}/rdf/output.$FILEFORMAT 


