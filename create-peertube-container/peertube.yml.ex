# Beispiel-Playbook mit LE-Zertifikats-Einrichtung
- hosts: all
  name: Konfiguriere Peertube Docker-Container mit Ansible
  gather_facts: no
  become: yes
  ### anpassen: Name des Remote-Users auf dem Dockerhost
  remote_user: linuxmuster
  vars:
    ### anpassen: Initiales Root-Passwort der Peertube-Instanz
    rootpw: '#Muster!'
    ### anpassen: FQDN der Peertube-Instanz
    hostname: 'peertube.docker.host'
    ### anpassen: Postgres-User- & Datenbank-Passwörter
    postgres_pw: 'peertube'
    db_pw: 'peertube'
    ### anpassen: nur wenn eigener Mailrelay verfügbar ist (kann nachträglich in .env angepasst werden)
    smtp_user: ''
    smtp_pw: ''
    smtp_host: 'postfix'
    smtp_port: '25'
    smtp_from: 'noreply@example.org'
    smtp_tls: 'false'
    smtp_disable_starttls: 'false'
    admin_email: 'ptadmin@example.org'

  tasks:

    - name: Make shure /srv/docker/peertube exists
      file:
        path: /srv/docker/peertube
        state: directory

    - name: Make shure /srv/docker/peertube/config exists
      file:
        path: /srv/docker/peertube/config
        state: directory

    - name: Make shure /srv/docker/peertube/data exists
      file:
        path: /srv/docker/peertube/data
        state: directory

    - name: Make shure /srv/docker/peertube/db exists
      file:
        path: /srv/docker/peertube/db
        state: directory

    - name: Make shure /srv/docker/peertube/redis exists
      file:
        path: /srv/docker/peertube/redis
        state: directory

    - name: Copy environment file
      copy:
        src: templates/env
        dest: /srv/docker/peertube/.env

    - name: Set PT_INITIAL_ROOT_PASSWORD for peertube
      lineinfile:
        dest: /srv/docker/peertube/.env
        regexp: "^PT_INITIAL_ROOT_PASSWORD"
        line: "PT_INITIAL_ROOT_PASSWORD={{ rootpw }}"
        state: present

    - name: Set PEERTUBE_WEBSERVER_HOSTNAME for peertube
      lineinfile:
        dest: /srv/docker/peertube/.env
        regexp: "^PEERTUBE_WEBSERVER_HOSTNAME"
        line: "PEERTUBE_WEBSERVER_HOSTNAME={{ hostname }}"
        state: present

    - name: Set POSTGRES_PASSWORD for peertube
      lineinfile:
        dest: /srv/docker/peertube/.env
        regexp: "^POSTGRES_PASSWORD"
        line: "POSTGRES_PASSWORD={{ postgres_pw }}"
        state: present

    - name: Set PEERTUBE_DB_PASSWORD for peertube
      lineinfile:
        dest: /srv/docker/peertube/.env
        regexp: "^PEERTUBE_DB_PASSWORD"
        line: "PEERTUBE_DB_PASSWORD={{ db_pw }}"
        state: present

    - name: Set PEERTUBE_SMTP_USERNAME for peertube
      lineinfile:
        dest: /srv/docker/peertube/.env
        regexp: "^PEERTUBE_SMTP_USERNAME"
        line: "PEERTUBE_SMTP_USERNAME={{ smtp_user }}"
        state: present

    - name: Set PEERTUBE_SMTP_PASSWORD for peertube
      lineinfile:
        dest: /srv/docker/peertube/.env
        regexp: "^PEERTUBE_SMTP_PASSWORD"
        line: "PEERTUBE_SMTP_PASSWORD={{ smtp_pw }}"
        state: present

    - name: Set PEERTUBE_SMTP_HOSTNAME for peertube
      lineinfile:
        dest: /srv/docker/peertube/.env
        regexp: "^PEERTUBE_SMTP_HOSTNAME"
        line: "PEERTUBE_SMTP_HOSTNAME={{ smtp_host }}"
        state: present

    - name: Set PEERTUBE_SMTP_PORT for peertube
      lineinfile:
        dest: /srv/docker/peertube/.env
        regexp: "^PEERTUBE_SMTP_PORT"
        line: "PEERTUBE_SMTP_PORT={{ smtp_port }}"
        state: present

    - name: Set PEERTUBE_SMTP_FROM for peertube
      lineinfile:
        dest: /srv/docker/peertube/.env
        regexp: "^PEERTUBE_SMTP_FROM"
        line: "PEERTUBE_SMTP_FROM={{ smtp_from }}"
        state: present

    - name: Set PEERTUBE_SMTP_TLS for peertube
      lineinfile:
        dest: /srv/docker/peertube/.env
        regexp: "^PEERTUBE_SMTP_TLS"
        line: "PEERTUBE_SMTP_TLS={{ smtp_tls }}"
        state: present

    - name: Set PEERTUBE_SMTP_DISABLE_STARTTLS for peertube
      lineinfile:
        dest: /srv/docker/peertube/.env
        regexp: "^PEERTUBE_SMTP_DISABLE_STARTTLS"
        line: "PEERTUBE_SMTP_DISABLE_STARTTLS={{ smtp_disable_starttls }}"
        state: present

    - name: Set PEERTUBE_ADMIN_EMAIL for peertube
      lineinfile:
        dest: /srv/docker/peertube/.env
        regexp: "^PEERTUBE_ADMIN_EMAIL"
        line: "PEERTUBE_ADMIN_EMAIL={{ admin_email }}"
        state: present

    - name: Copy docker-compose file
      copy:
        src: templates/docker-compose.yml
        dest: /srv/docker/peertube/docker-compose.yml

    - name: Copy nginx file
      copy:
        src: templates/nginx
        dest: /etc/nginx/sites-available/peertube

    - name: Replace hostname in nginx config
      replace:
        path: /etc/nginx/sites-available/peertube
        regexp: '@@hostname@@'
        replace: "{{ hostname }}"
      notify: Restart nginx

    - name: Enable nginx config
      file:
        src: /etc/nginx/sites-available/peertube
        dest: /etc/nginx/sites-enabled/peertube
        state: link
      notify: Restart nginx

    - name: Add hostname to dehydrated domains.txt
      lineinfile:
        dest: /etc/dehydrated/domains.txt
        line: "{{ hostname }}"
        state: present

    - name: Get certificate for {{ hostname }}
      command: /usr/bin/dehydrated --cron
      notify: Restart nginx

    - name: Start peertube container
      command: /usr/bin/docker-compose up -d
      args:
        chdir: /srv/docker/peertube/


  handlers:
    - name: Restart nginx
      service:
        name: nginx
        state: restarted
