#!/bin/bash

set -o nounset \
    -o errexit

printf "Deleting previous (if any)..."
rm -rf secrets
rm -rf tmp
mkdir secrets
mkdir -p tmp
echo " OK!"
# Generate CA key
printf "Creating CA..."
openssl req -new -x509 -keyout tmp/datahub-ca.key -out tmp/datahub-ca.crt -days 365 -subj '/CN=ca.datahub/OU=data/O=datahub/L=moscow/C=ru' -passin pass:datahub -passout pass:datahub >/dev/null 2>&1

echo " OK!"

for i in 'broker' 'producer' 'consumer'
do
	printf "Creating cert and keystore of $i..."
	# Create keystores
	keytool -genkey -noprompt \
				 -alias $i \
				 -dname "CN=$i, OU=data, O=datahub, L=moscow, C=ru" \
				 -keystore secrets/$i.keystore.jks \
				 -keyalg RSA \
				 -storepass datahub \
				 -keypass datahub  >/dev/null 2>&1

	# Create CSR, sign the key and import back into keystore
	keytool -keystore secrets/$i.keystore.jks -alias $i -certreq -file tmp/$i.csr -storepass datahub -keypass datahub >/dev/null 2>&1
	openssl x509 -req -CA tmp/datahub-ca.crt -CAkey tmp/datahub-ca.key -in tmp/$i.csr -out tmp/$i-ca-signed.crt -days 365 -CAcreateserial -passin pass:datahub  >/dev/null 2>&1
	keytool -keystore secrets/$i.keystore.jks -alias CARoot -import -noprompt -file tmp/datahub-ca.crt -storepass datahub -keypass datahub >/dev/null 2>&1
	keytool -keystore secrets/$i.keystore.jks -alias $i -import -file tmp/$i-ca-signed.crt -storepass datahub -keypass datahub >/dev/null 2>&1
	# Create truststore and import the CA cert.
	keytool -keystore secrets/$i.truststore.jks -alias CARoot -import -noprompt -file tmp/datahub-ca.crt -storepass datahub -keypass datahub >/dev/null 2>&1
  echo " OK!"
done

#keytool -exportcert -alias producer_cert -keystore secrets/producer.keystore.jks -rfc -file secrets/producer_cert.pem
#keytool -exportcert -alias consumer_cert -keystore secrets/consumer.keystore.jks -rfc -file secrets/consumer_cert.pem

#cp tmp/datahub-ca.crt secrets/datahub-ca.pem
#cp tmp/datahub-ca.key secrets/datahub-ca.key


echo "datahub" > secrets/cert_creds
#rm -rf tmp

echo "SUCCEEDED"