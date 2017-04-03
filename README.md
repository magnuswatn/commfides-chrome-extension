commfides-chrome-extension
=====

Jasså, så du har kjøpt deg elektronisk ID fra Commfides, men er lei deg for at den krever Java og Windows? Null stress, med denne crispe Chrome-utvidelsen kan den brukes i Chrome og på ditt favoritt-OS (les: Fedora).

(dette tillegget er laget av egeninteresse og har ingen knytning med Commfides)

![bilde](https://raw.githubusercontent.com/magnuswatn/commfides-chrome-extension/master/docs/bilde.png)


## Installasjon

### GNU/linux

Først må du installere noen pakker som "may, or may not" gjøre stygge ting med PC-en din mens du sover:

Fedora:

`# dnf install python-develop opensc gcc-c++ python-virtualenv` 

Ubuntu:

`# apt-get install python-dev opensc python-virtualenv` 

Last så ned releasen, pakk den ut på et logisk sted og kjør install.sh-scriptet for å installere Python-appen:

`./install.sh chrome`

eller:

`./install.sh firefox`


### Windows

Installer først [Python 2.7](https://www.python.org/) (husk å velge å legge den til i path) og [Microsoft Visual C++ Compiler for Python 2.7](https://aka.ms/vcpython27). Installer også enten [OpenSC](https://github.com/OpenSC/OpenSC/releases) eller produsenten sin driver til smartkortet.

Last så ned releasen, pakk den ut på et logisk sted og kjør install.bat-scriptet for å installere Python-appen.

---

Selve tillegget kan installeres fra [Chrome Web Store](https://chrome.google.com/webstore/detail/fdcjkappaacnnajkahkkcndafcipojag). Så er det bare å logge seg inn og kooose seg på allverdens slags offentlige tjenester.
