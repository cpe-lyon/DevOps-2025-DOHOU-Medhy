#!/bin/bash

# Check if the data folder exists
if [ -d /opt/tp-devops/medhy-dohou ];
then
    echo "Data folder doesn't exist"
    exit 0
fi

# If it doesn't, create it.
mkdir -p /tmp/tp-devops/medhy-dohou || echo "Cannot create data file, please check your permissions."
echo "Dossier pour données crée"