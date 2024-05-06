#!/bin/bash

# Install Python and dependencies
sudo apt update && sudo apt upgrade -y
sudo apt install software-properties-common -y
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update -y
sudo apt install python3.9 python3-pip python3-venv python3.9-dev -y

cd ../app
python3.9 -m venv venv
source venv/bin/activate
sudo pip install Flask==3.0.2 Waitress==3.0.0 Flask-SQLAlchemy==3.1.1 SQLAlchemy==2.0.27 PyMySQL==1.1.0 Jinja2==3.1.3 Flask-Waitress==0.0.1 cryptography
waitress-serve --port=5000 northwind_web:app > waitress.log 2>&1 &