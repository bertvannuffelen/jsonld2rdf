#!/bin/bash

# a simple build script
sudo docker build -t myjsonld .
sudo docker rm myjsonld0

DIR=/home/vagrant/OSLO/API-def/jsonldconvertor

sudo docker run -it --rm  --name myjsonld0 -v ${DIR}/rdf:/data/rdf  myjsonld ./jsonld2rdf.rb -v -o /data/rdf -f /data/rdf/test1.jsonld

