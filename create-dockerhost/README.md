# create-dockerhost
basiert auf https://github.com/linuxmuster-ext-docker/create-docker-host.git von @ironiemix

## Voraussetzung:

* Lokal: ansible + git installiert
* Remotehost:
  - Ubuntu 18.04 oder 20.04
  - ssh-Zugang für Sudo-Benutzer

## Inbetriebnahme:

* ``git clone https://github.com/linuxmuster/linuxmuster-docker/create-dockerhost.git``
* ``cd create-dockerhost``
* hosts-Datei kopieren: ``cp hosts.ex hosts``
* in hosts-Datei IP-Adresse oder FQDN des Remotehosts eintragen.
* Playbook-Datei kopieren: ``cp dockerhost.yml.ex dockerhost.yml``
* Playbook anpassen (siehe Zeilen mit "### anpassen"):
  - remote_user mit Sudo-Rechten (Bsp. linuxmuster),
  - Pfad zum ssh-Pubkey und
  - Hostname.
* Dockerhost ausrollen: ``ansible-playbook -i hosts -k -K dockerhost.yml``
  Passwort des Users wird zweimal abgefragt (für SSH & Sudo).
* Danach steht der Dockerhost mit passwortlosem SSH-Zugang zur Verfügung.


## Installierte Pakete u.a.:

* docker.io
* docker-compose
* ufw
* nginx
* dehydrated

## Anmerkungen:

* Es gibt zwei Beispiel-Playbooks:
- `dockerhost.yml.ex`
  Vollständiges Playbook mit Einrichtung von LE-Hostzertifikat über dehydrated. Gültiger DNS-Name des Hosts ist Voraussetzung.
  - `dockerhost-test.yml.ex`  
    Für den lokalen Testbetrieb, es wird kein LE-Zertifikat eingerichtet, im Internet gültiger FQDN ist nicht notwendig. In die Datei `hosts` kann eine private IP-Adresse eingetragen werden.

* ufw hat als default policy deny, erlaubt sind per default nur die Ports 80, 443 und 22. Man muss davon abweichende Ports von Containern also später explizit freigeben, damit nicht versehentlich beim Starten von Containern Dienste unbeabsichtigt exposed werden.

* **Die SSH Anmeldung per Passwort wird durch das Playbook deaktiviert**, man muss also vorher sicherstellen, dass man im Playbook den Pfad zum lokalen Public SSH Key korrekt angegeben hat, damit der übertragen wird. Alternativ kann die passwortlose SSH-Verbindung schon vorher eingerichtet werden. Dann muss die entsprechende Stelle auskommentiert werden.
