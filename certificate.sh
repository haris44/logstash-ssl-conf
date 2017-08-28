#!/bin/bash
echo 
echo -------------------------------
echo" SSL/JKS Generation by haris44 & Bastien BALAUD"
echo https://github.com/haris44/logstash-ssl-conf
echo -------------------------------
echo All data must be on lowercase 
echo You must have read/write rights on this folder
echo "Not working but it's really fun to debug bash"
echo -------------------------------
echo
read -p "Openssl.cnf path : " path 
read -p "Country : "  country
read -p "Location : "  location
read -p "Company : " company
read -p "Password : " -s password
echo
read -p "CA Name : " name

mkdir ${name}
cp ${path} ${name}/
mkdir ${name}/{private,newcerts,csr,certs}
cd ${name}

echo 00 > serial
echo 00 > crlnumber
touch index.txt

subjectCN="/C=${country}/L=${location}/O=${company} CA/CN=${company}.${country}"
subjectCl="/C=${country}/L=${location}/O=${company}/CN=client"
subjectSe="/C=${country}/L=${location}/O=${company}/CN=server"

# Create CA private key
openssl genrsa -des3 -passout pass:${password} -out private/${name}.key 2048

# Remove passphrase 
openssl rsa -passin pass:${password} -in private/${name}.key -out private/${name}.key

# Create CA self-signed certificate
openssl req -config openssl.cnf -new -x509 -subj "${subjectCN}" -days 999 -key private/${name}.key -out certs/${name}.crt


# Create private key for the server
openssl genrsa -des3 -passout pass:${password} -out private/server.key 2048

# Remove passphrase 
openssl rsa -passin pass:${password} -in private/server.key -out private/server.key

# Create CSR for the server server
openssl req -config openssl.cnf -new -subj "${subjectSe}" -key private/server.key -out csr/server.csr

# Create certificate for the server server
openssl ca -batch -config openssl.cnf -days 999 -in csr/server.csr -out certs/server.crt -keyfile private/${name}.key -cert certs/${name}.crt -policy policy_anything


# Create private key for a client
openssl genrsa -des3 -passout pass:${password} -out private/client.key 2048
 
# Remove passphrase 
openssl rsa -passin pass:${password} -in private/client.key -out private/client.key
 
# Create CSR for the client.
openssl req -config openssl.cnf -new -subj "${subjectCl}" -key private/client.key -out csr/client.csr
 
# Create client certificate.
openssl ca -batch -config openssl.cnf -days 999 -in csr/client.csr -out certs/client.crt -keyfile private/${name}.key -cert certs/${name}.crt -policy policy_anything

# create JKS

mkdir jks

keytool -genkey -alias temp -keystore jks/${name}.jks -storepass ${password}

keytool -delete -alias temp -keystore jks/${name}.jks -storepass ${password}

keytool -list -keystore jks/${name}.jks -storepass ${password}

keytool -import -alias alias -file certs/client.crt -keypass keypass -keystore jks/${name}.jks -storepass ${password}
