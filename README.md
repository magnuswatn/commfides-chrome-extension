commfides-chrome-extension
=====

Jasså, så du har kjøpt deg elektronisk ID fra Commfides, men er lei deg for at den kun funker på Windows? Null stress, med denne crispe Chrome-utvidelsen kan den brukes også på ditt favoritt-OS (les: Fedora).

![bilde](https://raw.githubusercontent.com/magnuswatn/commfides-chrome-extension/master/docs/bilde.png)

(dette tillegget er laget av egeninteresse og har ingen knytning med Commfides)

## Installasjon

Først må du installere noen pakker som "may, or may not" gjøre stygge ting med PC-en din mens du sover:

Fedora:

`# dnf install python-develop opensc gcc-c++ python-virtualenv` 

Ubuntu:

`# apt-get install python-dev opensc python-virtualenv` 

Last så ned releasen, og pakk den ut på et logisk sted. Installer tillegget ved å dra crx-filen over til Chrome, og kjør install.sh-scriptet for å installere Python-appen.

Så er det bare å logge seg inn og kooose seg på allverdens slags offentlige tjenester.
