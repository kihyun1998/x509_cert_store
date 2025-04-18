```bash
openssl req -x509 -newkey rsa:2048 -sha256 -days 365 -nodes \
  -keyout mycompany.key -out mycompany.crt \
  -subj "/CN=mycompany.com" \
  -addext "subjectAltName=DNS:mycompany.com,DNS:www.mycompany.com"
```

```bash
openssl x509 -in mycompany.crt -outform DER | base64
```