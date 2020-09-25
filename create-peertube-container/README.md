# create-peertube-container

Erstellt einen Peertube Docker-Container.  
Basiert auf https://github.com/Chocobozzz/PeerTube.

## Voraussetzung:

* Lokal: ansible + git installiert
* Dockerhost:
  - Ubuntu 18.04 oder 20.04
  - Installierte Pakete: docker.io, docker-compose, nginx, dehydrated
  - nginx & dehydrated konfiguriert mit LE-Zertifikat für Dockerhost
  - passwortloser ssh-Zugang für Sudo-Benutzer

## Inbetriebnahme:

* Repo klonen: ``git clone https://github.com/linuxmuster/linuxmuster-docker.git``
* Ins Verzeichnis wechseln: ``cd linuxmuster-docker/create-peertube-container``
* hosts-Datei kopieren: ``cp hosts.ex hosts``
* in hosts-Datei IP-Adresse oder FQDN des Dockerhosts eintragen.
* Playbook-Datei kopieren: ``cp peertube.yml.ex peertube.yml``
* Playbook anpassen (siehe Zeilen mit "### anpassen"):
  - remote_user: Name des Remote-Users auf dem Dockerhost,
  - rootpw: Initiales Root-Passwort der Peertube-Instanz und
  - hostname: FQDN der Peertube-Instanz
* Anpassen der Mailrelay-Daten optional, nur wenn eigener Mailrelay verfügbar ist (kann auch noch nachträglich in .env-Datei gemacht werden).
* Dockerhost ausrollen: ``ansible-playbook -i hosts -K peertube.yml``  
  Sudo-Passwort des Users wird abgefragt.
* Danach kann man sich als ``root`` per https auf der unter ``hostname`` angegebenen Adresse anmelden.
* Unter _Administration -> Plugins/Designs -> Search_ lässt man sich die installierbaren Plugins auflisten.  
![PeerTube Plugins](pt-plugins.png)
* In der Pluginliste sucht man das auth-ldap-Plugin und installiert es.
![LDAP-Plugin installieren](auth-ldap-installieren.png)
* Unter _Administration -> Plugins/Designs -> Installiert_ öffnet man die Einstellungen des Plugins.
![LDAP-Plugin Einstellungen](auth-ldap-einrichten1.png)
* Das Formular ist mit den entsprechenden Werten auszufüllen:  
![LDAP-Plugin Formular](auth-ldap-einrichten2.png)  
  Bezeichnung       | Wert
  ------------------|-----------------------------------------------------------------------
  URL               | ``ldaps://server.example.org``
  Bind DN           | ``CN=global-binduser,OU=Management,OU=GLOBAL,DC=example,DC=org``
  Bind Password     | (siehe auf dem Server in ``/etc/linuxmuster/.secret/global-binduser``)
  Search base       | ``OU=teachers,OU=default-school,OU=SCHOOLS,DC=example,DC=org``
  Search filter     | ``(sAMAccountName={{username}})``
  mail              | ``mail``
  Username property | ``sAMAccountName`

## Anmerkungen

* Es gibt eine Beispieldatei ``peertube-test.yml.ex``, die zum Testen benutzt werden kann. Damit wird kein LE-Zertifikat für die PeerTube-Instanz eingerichtet. Bitte beachten, dass für den unverschlüsselten Zugriff die Firewall auf Port 9000 geöffnet wird.
* Konfiguration und Daten werden persistent in den Volumes ``./config`` und ``./data`` abgelegt. Die hochgeladenden Videos finden sich z.Bsp. ``./data/videos``.
* Die Datenbanken legen ihre Dateien in den Volumes ``db`` und ``redis`` persistent ab.
* Um die komplette Instanz zu sichern, bezieht man einfach das Verzeichnis ``/srv/docker/peertube`` in seine Backupkonfiguration ein.
