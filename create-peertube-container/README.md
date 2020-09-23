# create-peertube-container

Erstellt einen Peertube Docker-Container.  
Basiert auf https://github.com/Chocobozzz/PeerTube.

## Voraussetzung:

* Lokal: ansible + git installiert
* Remotehost:
  - Ubuntu 18.04 oder 20.04
  - Installierte Pakete: docker.io, docker-compose, nginx, dehydrated
  - passwortloser ssh-Zugang für Sudo-Benutzer

## Inbetriebnahme:

* Repo klonen: ``git clone https://github.com/linuxmuster/linuxmuster-docker.git``
* Ins Verzeichnis wechseln: ``cd linuxmuster-docker/create-peertube-container``
* hosts-Datei kopieren: ``cp hosts.ex hosts``
* in hosts-Datei IP-Adresse oder FQDN des Remotehosts eintragen.
* Playbook-Datei kopieren: ``cp peertube.yml.ex peertube.yml``
* Playbook anpassen (siehe Zeilen mit "### anpassen"):
  - remote_user: Name des Remote-Users auf dem Dockerhost,
  - rootpw: Initiales Root-Passwort der Peertube-Instanz und
  - hostname: 
