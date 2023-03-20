#!/bin/sh
# set -x

localhostaddress="127.0.0.1"
hostsconf_path="/etc/hosts"

usage(){
    printf "Usage: $(basename $0) <list of hosts>"
}

clearspaces(){
    printf "\r"
    for i in {1..$COLUMNS}; do
        printf "     "
    done
    printf "\r"
}

createvirtualhost(){
    httpdvhostsconfig_path=/etc/httpd/conf/extra/httpd-vhosts.conf
    webmaster="$1"
    webserverroot="/srv/http/"  # Web server root folder 
    documentroot="$1"
    servername="$1"
    webserverfullpath="${webserverroot}${documentroot}/"

    printf "\r[+] Checking if httpd-vhosts is available"
    if [[ ! -f "${httpdvhostsconfig_path}" ]]; then
        printf "\r[-] Install apache to proceed";
        exit 1
    fi
    printf "\r[+] File $httpdvhostsconfig_path is available"


    printf "\r[+] Checking if $webserverfullpath is available"
    if [[ ! -d "$webserverfullpath" ]]; then
        printf "\r[+] Creating $webserverfullpath "
        sudo mkdir "$webserverfullpath"
        if [[ $? -eq 1 ]]; then
            printf "\r[-] Unable to create ${webserverfullpath}";
            exit 2
        fi
        printf "\r[+] Created ${webserverfullpath}"
    else
        printf "\r[-] Root folder is available ...  "
    fi

    printf "\r[+] Setting $USER as the owner of ${webserverfullpath}"
    sudo chown $USER:$USER -R ${webserverfullpath}
    if [[ $? -eq 1 ]]; then
        printf "\r[-] Unable to set permissions for ${webserverfullpath}";
        exit 3
    fi

    clearspaces
    printf "\r[+] Root folder,  permission set successully"

    printf "\r[+] Creating ${webserverfullpath}test.php"
    printf "<?php phpinfo(); ?>" > ${webserverfullpath}test.php
    printf "\r[+] Created ${webserverfullpath}test.php"


    grep "ServerAdmin webmaster@$1" ${httpdvhostsconfig_path} >/dev/null 2>&1
    if [[ ! $? -eq 1 ]]; then
        clearspaces
        printf "\r[-] Skipping adding virtual host configurations ...";
    else
        sudo sed --in-place "\$a\ " ${httpdvhostsconfig_path}
        sudo sed --in-place "\$a\<VirtualHost *:80>" ${httpdvhostsconfig_path}
        sudo sed --in-place "\$a\    ServerAdmin webmaster@${webmaster}" ${httpdvhostsconfig_path}
        sudo sed --in-place "\$a\    DocumentRoot \"${webserverfullpath}\"" ${httpdvhostsconfig_path}
        sudo sed --in-place "\$a\    ServerName ${servername}" ${httpdvhostsconfig_path}
        sudo sed --in-place "\$a\    ErrorLog \"/var/log/httpd/${servername}-error_log\"" ${httpdvhostsconfig_path}
        sudo sed --in-place "\$a\    CustomLog \"/var/log/httpd/${servername}-access_log\" common" ${httpdvhostsconfig_path}
        sudo sed --in-place "\$a\</VirtualHost>" ${httpdvhostsconfig_path}
    fi

    printf "\r[+] Virtual Host folder $1 is successfully set up ..."

}

addhostaddresses(){

    count=0
    while [[ $# -gt 0 ]]; do
        printf "[~] Setting up  [ $1 ] virtual host ......\n"
        createvirtualhost $1

        if [[ ! -f $hostsconf_path ]]; then
            printf  "\r[-] $hospath is not available"
            printf "[+] Creating $hostsconf_path"
            sudo touch $hostsconf_path
            printf "\r[+] Created $hostsconf_path"
        else
            printf "\n[+] Updating $hostsconf_path"
        fi

        grep "127.0.0.1  $1" $hostsconf_path >/dev/null 2>&1
        if [[ $? -eq 1 ]]; then
            if [[ $count -eq 0 ]]; then
                sudo sed --in-place "1a\ " $hostsconf_path
                count=$((count + 1))
            fi
            sudo sed --in-place "1a\127.0.0.1  $1" $hostsconf_path
        else
            printf "\r[-] Skipping $1 already an included host"
        fi

        clearspaces
        printf "                                                                "
        printf "\r[+] Restarting apache server"
        sudo systemctl restart httpd.service
        printf  "\r[+] Restarted apache server\n"
        set +x

        printf "\n[+]---------------\n"
        printf "   [~] Everything is set up.\n"
        printf "      + Fireup your browser and place \"$1\" as url\n"
        printf "      * NOTE:\n"
        printf "\t   Incase of connection not establised try reloading ...\n"
        printf "\t   and ENSURE IT IS HTTP NOT HTTPS\n\t\t http://$1\n"
        printf "\t   or click the link above ... \n\n"
        printf "[+]---------------\n"

        shift
    done
}

if [[ $# -eq 0 ]]; then
   usage
   exit
fi

addhostaddresses $*

# If we are here everything worked ...
printf "\n> Done! enjoy -- \n"

echo  && exit
