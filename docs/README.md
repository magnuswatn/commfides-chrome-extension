# Dokumenasjon

Commfides sender fra seg to verdier; en kontrollverdi og en hash. Hashen er en SHA256-hash i en ASN.1-struktur, klar til å signeres PKCS# version 1.5-style. Tillegget henter ut disse via injisert Javascript i siden, og sender hash + pin-koden til Python-scriptet som signerer den med smartkortet vha. OpenSC og PyKCS11. Så returneres den signerte hashen, kontrollverdien og sertifikatet til Commfides via et skjult skjema i siden (samme måte som Java-applet-en gjør).


### Meldinger som går mellom Python og Chrome
 
Melding fra Chrome:
```json
{
    "operation": "sign",
    "params" : {
        "pin":  "1234",
        "hash": "b64-enkodet hash"
    }
}
```
 
Melding tilbake:
```json
{
    "status": "success",
    "params": {
        "cert": "B64-enkodet cert",
        "signedHash": "b64-enkodet signert hash"
    }
}
```

Ved feil:
```json
{
    "status": "error",
    "message": "something went horribly wrong"
}
```
