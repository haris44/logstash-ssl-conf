#!/bin/bash
echo 
echo -------------------------------
echo SSL/JKS Generation by haris44
echo https://github.com/haris44/logstash-ssl-conf
echo -------------------------------
echo All data must be on lowercase 
echo You must have read/write rights on this folder
echo -------------------------------

read -p "Openssl.cnf path : " openssl 
read -p "Path where new certificate will be generate : " path 
read -s -p "Password : " password
echo
read -p "CA name : " name

mkdir ${path}
cp ${openssl} ${path}/openssl.cnf
cd ${path}

# Generate .crt and .key
# ======================
openssl req -x509 -batch -nodes -days 3650 -newkey rsa:2048 -keyout ${name}.key -out ${name}.crt -config openssl.cnf

# Create JKS 
# ======================
keytool -genkey -alias temp -keystore ${name}.jks -storepass ${password}
keytool -import -alias alias -file ${name}.crt -keypass keypass -keystore ${name}.jks-storepass ${password}
