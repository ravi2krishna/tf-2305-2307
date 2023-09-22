#!/bin/bash
sudo apt -y update
sudo apt -y install apache2
sudo rm -rf /var/www/html/*
sudo git clone https://github.com/ravi2krishna/ecomm.git /var/www/html