- hosts: all
  name: Konfiguriere Dockerhost mit Ansible
  gather_facts: yes
  become: yes
  ### anpassen
  remote_user: linuxmuster
  vars:

    required_packages:
      - ufw
      - curl
      - apt-transport-https
      - ca-certificates
      - gnupg2
      - software-properties-common
      - fail2ban
      - vim
      - nginx
      - dehydrated
      - docker.io
      - docker-compose

    ssh_port: '22'
    http_port: '80'
    https_port: '443'
    ### anpassen
    hostname: 'mein.docker.host'

  tasks:
    - name: get lsb_release
      shell: lsb_release -cs
      register: release
    - set_fact:
           lsb_release={{ release.stdout }}

    - name: Get system type
      shell: uname -s
      register: unames
    - set_fact:
           system={{ unames.stdout }}

    - name: Get system architecture
      shell: uname -m
      register: unamem
    - set_fact:
           arch={{ unamem.stdout }}

    - name: Update APT package cache
      apt: update_cache=yes

    - name: Upgrade APT to the latest packages
      apt: upgrade=safe

    - name: Install required packages
      apt: state=present pkg={{ required_packages }}

    - name: Set authorized key taken from file
      authorized_key:
        ### anpassen
        user: linuxmuster
        state: present
        ### anpassen
        key: "{{ lookup('file', '/home/linuxmuster/.ssh/id_rsa.pub') }}"

    - name: Disallow ssh password authentication
      lineinfile: dest=/etc/ssh/sshd_config
                  regexp="^PasswordAuthentication"
                  line="PasswordAuthentication no"
                  state=present
      notify: Restart ssh

    - name: Disallow root SSH access with passwords
      lineinfile: dest=/etc/ssh/sshd_config
                  regexp="^PermitRootLogin"
                  line="PermitRootLogin without-password"
                  state=present
      notify: Restart ssh

    - name: Set hostname to {{ hostname }}
      command: /usr/bin/hostnamectl set-hostname {{ hostname }}

    - name: Create WellKnown directory for dehydrated challenges
      file:
         path: /var/www/dehydrated
         state: directory
         owner: www-data
         group: www-data
         mode: 0755

    - name: Set WELLKNOWN for dehydrated
      lineinfile: dest=/etc/dehydrated/config
                  regexp="^WELLKNOWN"
                  line="WELLKNOWN=/var/www/dehydrated"
                  state=present
      notify: Restart ssh

    - name: Create domain.txt for dehydrated
      copy:
        content: "{{ hostname }}"
        dest: /etc/dehydrated/domain.txt

    - name: Insert .wellknown alias into nginx configuration
      blockinfile:
        path: /etc/nginx/sites-available/default
        marker: "## {mark} ANSIBLE MANAGED BLOCK"
        insertafter: "server_name _;"
        content: |
          location ^~ /.well-known/acme-challenge {
              alias /var/www/dehydrated;
          }
      notify: Restart nginx

    - name: Registering host with letsencrypt
      command: /usr/bin/dehydrated --register --accept-terms

    - name: Creating cronjob for dehydrated
      template: src=./files/dehydrated.cron.daily dest=/etc/cron.daily/dehydrated

    - name: Getting certificate for {{ hostname }}
      command: /usr/bin/dehydrated --cron

    - name: Setup ufw
      ufw: state=enabled policy=deny

    - name: Allow SSH on port {{ ssh_port }}
      ufw: rule=allow port={{ ssh_port }} proto=tcp
    - name: Allow HTTP on port {{ http_port }}
      ufw: rule=allow port={{ http_port }} proto=tcp
    - name: Allow HTTPs on port {{ https_port }}
      ufw: rule=allow port={{ https_port }} proto=tcp

    - name: make shure /srv/docker exists
      file:
        path: /srv/docker
        state: directory

    - name: vim als Standard-Editor festlegen
      alternatives:
        name: editor
        path: /usr/bin/vim.tiny


  handlers:
    - name: Restart ssh
      service: name=ssh state=restarted
    - name: Restart nginx
      service: name=nginx state=restarted
