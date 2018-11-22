#!/bin/bash

CSI="\033["
CEND="${CSI}0m"
CRED="${CSI}1;31m"
CGREEN="${CSI}1;32m"
CPURPLE="${CSI}1;35m"
CCYAN="${CSI}1;36m"

###################################################################################################################################################

progress-bar() {
  local duration=${1}
printf '\n'
echo -e "${CGREEN}Patientez ...	${CEND}"
printf '\n'

    already_done() { for ((done=0; done<$elapsed; done++)); do printf "#"; done }
    remaining() { for ((remain=$elapsed; remain<$duration; remain++)); do printf " "; done }
    percentage() { printf "| %s%%" $(( (($elapsed)*100)/($duration)*100/100 )); }
    clean_line() { printf "\r"; }

  for (( elapsed=1; elapsed<=$duration; elapsed++ )); do
      already_done; remaining; percentage
      sleep 0.2
      clean_line
  done
  clean_line
printf '\n'
}

clear
logo.sh 
echo ""
echo -e "${CCYAN}INSTALLATION${CEND}"
	echo -e "${CGREEN}${CEND}"
	echo -e "${CGREEN}   1) Installation de docker && docker-compose (Ubuntu, Debian) ${CEND}"
	echo -e "${CGREEN}   2) Configuration du docker-compose ${CEND}"
	echo -e "${CGREEN}   3) Applications ${CEND}"
	echo -e "${CGREEN}   4) Sécuriser la Seedbox ${CEND}"
	echo -e "${CGREEN}   5) Sauvegarde && Restauration${CEND}"
	echo -e "${CGREEN}   6) Quitter ${CEND}"
	echo -e ""
	until [[ "$PORT_CHOICE" =~ ^[1-6]$ ]]; do
		read -p "Votre choix [1-6]: " -e -i 1 PORT_CHOICE
	done

	case $PORT_CHOICE in
		1) ## Installation de docker et docker-compose
			logo.sh
			echo -e "${CGREEN}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			echo -e "${CCYAN}					INSTALLATION DOCKER ET DOCKER-COMPOSE						   ${CEND}"
			echo -e "${CGREEN}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			echo ""
			# Installation possible sur debian ou ubuntu
			OS=$(cat /etc/*release | grep ^NAME | tr -d 'NAME="')
			if [ "$OS" = "Ubuntu" ]
			then
				apt update && apt upgrade -y \
				apt-get install -y \
				curl
				unzip
				apt install docker.io apache2-utils -y
				curl https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh | sh
                        	curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
                        	chmod +x /usr/local/bin/docker-compose
				mkdir -p /etc/apache2
				touch /etc/apache2/.htpasswd
				clear
				logo.sh
				echo -e "${CCYAN}Installation docker & docker compose terminée${CEND}"
				echo ""
				read -p "Appuyer sur la touche Entrer pour revenir au menu principal"
				seedbox.sh

			else
				apt update && apt upgrade -y
				apt install -y \
				apache2-utils \
				unzip \
                        	apt-transport-https \
                        	ca-certificates \
                        	curl \
                        	gnupg2 \
				lsb-release \
                        	software-properties-common
                        	curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
				curl https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh | sh
                        	add-apt-repository \
                        	"deb [arch=amd64] https://download.docker.com/linux/debian \
                        	$(lsb_release -cs) \
                        	stable"
                        	apt update
                        	apt install docker-ce -y
                        	curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
                        	chmod +x /usr/local/bin/docker-compose
				clear
				logo.sh
				echo -e "${CCYAN}Installation docker & docker compose terminée${CEND}"
				echo ""
				read -p "Appuyer sur la touche Entrer pour revenir au menu principal"
				seedbox.sh

				fi

		;;

		2) 	## Mise en place des variables necéssaire au docker-compose
			clear
			logo.sh			
			echo -e "${CCYAN}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			echo -e "${CCYAN}					PRECISONS SUR LES VARIABLES							  ${CEND}"
			echo -e "${CCYAN}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			echo -e "${CGREEN}		Cette étape permet une installation personnalisée configurable à vos besoins				 ${CEND}"	
			echo -e "${CGREEN}		Une fois les variables définies, la configuration sera complètement automatisée 			 ${CEND}"
			echo -e "${CRED}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			echo -e "${CCYAN}															 ${CEND}"
			echo -e "${CCYAN}				UNE ATTENTION PARTICULIERE EST REQUISE POUR CETTE ETAPE					 ${CEND}"
			echo -e "${CCYAN}															 ${CEND}"
			echo -e "${CCYAN}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			echo -e "${CGREEN}${CEND}"
			## définition des variables

			echo -e "${CCYAN}Nom de domaine ${CEND}"
			read -rp "DOMAIN = " DOMAIN

			if [ -n "$DOMAIN" ]
			then
			 	export DOMAIN
			fi

			echo  ""
			echo -e "${CCYAN}Nom d'utilisateur pour l'authentification WEB ${CEND}"
			read -rp "USERNAME = " USERNAME

			if [ -n "$USERNAME" ]
			then
			 	export USERNAME
				mkdir -p /etc/apache2
				VAR=$(htpasswd -c /etc/apache2/.htpasswd $USERNAME 2>/dev/null)
				VAR=$(sed -e 's/\$/\$$/g' /etc/apache2/.htpasswd 2>/dev/null)
				export VAR
			fi
			
			echo ""
			echo -e "${CCYAN}Adresse mail ${CEND}"
			read -rp "MAIL = " MAIL

			if [ -n "$MAIL" ]
			then
			 	export MAIL
			fi
			
			echo ""
			read -rp "Souhaitez vous utiliser Nextcloud ? (o/n) : " EXCLUDE
			if [[ "$EXCLUDE" = "o" ]] || [[ "$EXCLUDE" = "O" ]]; then
	
				echo -e "${CGREEN}${CEND}"
				read -rp "Choisir un mot de passe pour la base de donnée MARIADB = " PASS

				if [ -n "$PASS" ]
				then
			 		export PASS
					echo -e "${CGREEN}Vous devrez lancer nextcloud à partir des applications choix 3${CEND}"
				fi
			fi

			clear
			echo -e "${CCYAN}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			echo -e "${CGREEN}															  ${CEND}"
			echo -e "${CGREEN}				LA VARIABLE CI DESSOUS EST DEFINIE PAR DEFAULT SUR L HOTE			  	  ${CEND}"
			echo -e "${CGREEN}															  ${CEND}"
			echo -e "${CCYAN}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			echo -e "${CCYAN}	  ${CPURPLE}VOLUMES_ROOT_PATH:${CRED} Emplacement des volumes sur l'hote:	${CCYAN}/home/predator999	  ${CEND}"
			echo -e "${CCYAN}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			echo -e "${CGREEN}															  ${CEND}"
			echo -e "${CGREEN}				TU PEUX MODIFIER CETTE VARIABLE A TA CONVENANCE						  ${CEND}"
			echo -e "${CGREEN}															  ${CEND}"
			echo -e "${CRED}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			echo -e "${CGREEN}${CEND}"
			
			# Variables par défault, peuvent être modifiée
			export VOLUMES_ROOT_PATH=/home/predator999


			read -rp "Voulez modifier la variable ci dessus ? (o/n) : " EXCLUDE
				if [[ "$EXCLUDE" = "o" ]] || [[ "$EXCLUDE" = "O" ]]; then
	
					echo -e "${CGREEN}${CEND}"
					echo -e "${CCYAN}Par défault le montage des volumes est dans : /home/predator999 ${CEND}"
					read -rp "VOLUMES_ROOT_PATH = " VOLUMES_ROOT_PATH

						if [ -n "$VOLUMES_ROOT_PATH" ]
						then
			 				export VOLUMES_ROOT_PATH
						else
			 				VOLUMES_ROOT_PATH=/home/predator999
			 				export VOLUMES_ROOT_PATH
						fi
				fi

			clear
			echo -e "${CCYAN}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			echo -e "${CGREEN}															  ${CEND}"
			echo -e "${CGREEN}				ORGANISATION DES DOSSIERS DE MEDIAS							  ${CEND}"
			echo -e "${CGREEN}															  ${CEND}"
			echo -e "${CCYAN}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			echo -e "${CGREEN}															  ${CEND}"
			echo -e "${CCYAN}			        exemple: Movies, Shows, Musics, Animes							  ${CEND}"
			echo -e "${CGREEN}															  ${CEND}"
			echo -e "${CCYAN}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			
			## Création des dossiers locaux pour unionfs
			mkdir -p ${VOLUMES_ROOT_PATH}
			touch ${VOLUMES_ROOT_PATH}/local.txt	
			read -rp "Taper ok pour démarrer: " EXCLUDE
			cat <<- EOF > ${VOLUMES_ROOT_PATH}/local.txt
			EOF

			if [[ "$EXCLUDE" = "ok" ]] || [[ "$EXCLUDE" = "OK" ]]; then
    			echo -e "${CCYAN}\nTapez le nom des dossiers dans lesquels seront stockés les Medias, à la fin de chaque saisie appuyer sur la touche Entrée et taper ${CPURPLE}STOP${CEND}${CCYAN} si vous avez terminé.\n${CEND}"
    			while :
    			do		
        		read -p "" EXCLUDEPATH
        			if [[ "$EXCLUDEPATH" = "STOP" ]] || [[ "$EXCLUDEPATH" = "stop" ]]; then
            			break
        			fi
        		echo "$EXCLUDEPATH" >> ${VOLUMES_ROOT_PATH}/local.txt
    			done
			fi

			while IFS=: read user
			do
			mkdir -p ${VOLUMES_ROOT_PATH}/Medias/$user
			done < ${VOLUMES_ROOT_PATH}/local.txt

			FILMS=$(grep -E 'films|film|Films|FILMS|MOVIES|Movies|movies|movie|VIDEOS|VIDEO|Video|Videos' ${VOLUMES_ROOT_PATH}/local.txt | cut -d: -f2 | cut -d ' ' -f2)
			SERIES=$(grep -E 'series|TV|tv|Series|SERIES|SERIES TV|Series TV|series tv|serie tv|serie TV|series TV|Shows' ${VOLUMES_ROOT_PATH}/local.txt | cut -d: -f2 | cut -d ' ' -f2-3)
			ANIMES=$(grep -E 'ANIMES|ANIME|Animes|Anime|Animation|ANIMATION|animes|anime' ${VOLUMES_ROOT_PATH}/local.txt | cut -d: -f2 | cut -d ' ' -f2)
			MUSIC=$(grep -E 'MUSIC|Music|music|Musiques|Musique|MUSIQUE|MUSIQUES|musiques|musique' ${VOLUMES_ROOT_PATH}/local.txt | cut -d: -f2 | cut -d ' ' -f2)
			
			export FILMS
			export SERIES
			export ANIMES
			export MUSIC
			rm ${VOLUMES_ROOT_PATH}/local.txt

			clear
			echo -e "${CCYAN}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			echo -e "${CCYAN}				LES VARIABLES CI DESSOUS DONT DEFINIES PAR DEFAULT				  ${CEND}"
			echo -e "${CCYAN}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			echo -e "${CRED}	${CCYAN}TRAEFIK_DASHBOARD_URL:${CRED}	traefik.${DOMAIN}	  						  ${CEND}"
			echo -e "${CRED}	${CCYAN}PLEX_FQDN:${CRED}		plex.${DOMAIN} 			  				  	  ${CEND}"
			echo -e "${CRED}	${CCYAN}PYLOAD_FQDN:${CRED}		pyload.${DOMAIN}							  ${CEND}"
			echo -e "${CRED}	${CCYAN}MEDUSA_FQDN:${CRED}		medusa.${DOMAIN}							  ${CEND}"
			echo -e "${CRED}	${CCYAN}RTORRENT_FQDN:${CRED}		rtorrent.${DOMAIN}							  ${CEND}"
			echo -e "${CRED}	${CCYAN}RADARR_FQDN:${CRED}		radarr.${DOMAIN}							  ${CEND}"
			echo -e "${CRED}	${CCYAN}SYNCTHING_FQDN:${CRED}		syncthing.${DOMAIN}							  ${CEND}"
			echo -e "${CRED}	${CCYAN}JACKETT_FQDN:${CRED}		jackett.${DOMAIN}							  ${CEND}"
			echo -e "${CRED}	${CCYAN}LIDARR_FQDN:${CRED}		lidarr.${DOMAIN}							  ${CEND}"
			echo -e "${CRED}	${CCYAN}PORTAINER_FQDN:${CRED}		portainer.${DOMAIN}							  ${CEND}"
			echo -e "${CRED}	${CCYAN}TAUTULLI_FQDN:${CRED}		tautulli.${DOMAIN}							  ${CEND}"
			echo -e "${CRED}	${CCYAN}NEXTCLOUD_FQDN:${CRED}		nextcloud.${DOMAIN}							  ${CEND}"
			echo -e "${CRED}	${CCYAN}HEIMDALL_FQDN:${CRED}		heimdall.${DOMAIN}							  ${CEND}"
			echo -e "${CRED}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			echo -e "${CGREEN}				VOUS POUVEZ MODIFIER TOUTES CES VARIABLES A VOTRE CONVENANCE				  ${CEND}"	
			echo -e "${CGREEN}				TAPER ENSUITE SUR LA TOUCHE ENTREE POUR VALIDER 					  ${CEND}"
			echo -e "${CRED}-------------------------------------------------------------------------------------------------------------------------${CEND}"

			export PROXY_NETWORK=traefik_proxy
			export TRAEFIK_DASHBOARD_URL=traefik.${DOMAIN}
			export PLEX_FQDN=plex.${DOMAIN}
			export PYLOAD_FQDN=pyload.${DOMAIN}
			export MEDUSA_FQDN=medusa.${DOMAIN}
			export RTORRENT_FQDN=rtorrent.${DOMAIN}
			export RADARR_FQDN=radarr.${DOMAIN}
			export SYNCTHING_FQDN=syncthing.${DOMAIN}
			export JACKETT_FQDN=jackett.${DOMAIN}
			export LIDARR_FQDN=lidarr.${DOMAIN}
			export PORTAINER_FQDN=portainer.${DOMAIN}
			export TAUTULLI_FQDN=tautulli.${DOMAIN}
			export NEXTCLOUD_FQDN=nextcloud.${DOMAIN}
			export HEIMDALL_FQDN=heimdall.${DOMAIN}

			read -rp "Voulez-vous modifier les variables ci dessus ? (o/n) : " EXCLUDE
			echo""
				if [[ "$EXCLUDE" = "o" ]] || [[ "$EXCLUDE" = "O" ]]; then

			echo -e "${CCYAN}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			echo -e "${CCYAN}				JUSTE SAISIR LE SOUS DOMAINE ET NON LE DOMAINE						  ${CEND}"
			echo -e "${CCYAN}-------------------------------------------------------------------------------------------------------------------------${CEND}"

					echo -e "${CCYAN}Sous domaine de Traefik${CEND}"
					read -rp "TRAEFIK_DASHBOARD_URL = " TRAEFIK_DASHBOARD_URL

						if [ -n "$TRAEFIK_DASHBOARD_URL" ]
						then
			 				export TRAEFIK_DASHBOARD_URL=${TRAEFIK_DASHBOARD_URL}.${DOMAIN}
						else
			 				TRAEFIK_DASHBOARD_URL=traefik.${DOMAIN}
			 				export TRAEFIK_DASHBOARD_URL
						fi

					echo -e "${CGREEN}${CEND}"
					echo -e "${CCYAN}Sous domaine de Plex${CEND}"
					read -rp "PLEX_FQDN = " PLEX_FQDN

						if [ -n "$PLEX_FQDN" ]
						then
							export PLEX_FQDN=${PLEX_FQDN}.${DOMAIN}
						else
			 				PLEX_FQDN=plex.${DOMAIN}
			 				export PLEX_FQDN
						fi

					echo -e "${CGREEN}${CEND}"
					echo -e "${CCYAN}Sous domaine de pyload${CEND}"
					read -rp "PYLOAD_FQDN = " PYLOAD_FQDN

						if [ -n "$PYLOAD_FQDN" ]
						then
			 				export PYLOAD_FQDN=${PYLOAD_FQDN}.${DOMAIN}
						else
			 				PYLOAD_FQDN=pyload.${DOMAIN}
			 				export PYLOAD_FQDN
						fi

					echo -e "${CGREEN}${CEND}"
					echo -e "${CCYAN}Sous domaine de Medusa${CEND}"
					read -rp "MEDUSA_FQDN = " MEDUSA_FQDN

						if [ -n "$MEDUSA_FQDN" ]
						then
			 				export MEDUSA_FQDN=${MEDUSA_FQDN}.${DOMAIN}
						else
			 				MEDUSA_FQDN=medusa.${DOMAIN}
			 				export MEDUSA_FQDN
						fi

					echo -e "${CGREEN}${CEND}"
					echo -e "${CCYAN}Sous domaine de Rtorrent${CEND}"
					read -rp "RTORRENT_FQDN = " RTORRENT_FQDN

						if [ -n "$RTORRENT_FQDN" ]
						then
			 				export RTORRENT_FQDN=${RTORRENT_FQDN}.${DOMAIN}
						else
			 				RTORRENT_FQDN=rtorrent.${DOMAIN}
			 				export RTORRENT_FQDN
						fi

					echo -e "${CGREEN}${CEND}"
					echo -e "${CCYAN}Sous domaine de Radarr${CEND}"
					read -rp "RADARR_FQDN = " RADARR_FQDN

						if [ -n "$RADARR_FQDN" ]
						then
			 				export RADARR_FQDN=${RADARR_FQDN}..${DOMAIN}
						else
			 				RADARR_FQDN=radarr.${DOMAIN}
			 				export RADARR_FQDN
						fi

					echo -e "${CGREEN}${CEND}"
					echo -e "${CCYAN}Sous domaine de syncthing${CEND}"
					read -rp "SYNCTHING_FQDN = " SYNCTHING_FQDN

						if [ -n "$SYNCTHING_FQDN" ]
						then
			 				export SYNCTHING_FQDN=${SYNCTHING_FQDN}.${DOMAIN}
						else
			 				SYNCTHING_FQDN=syncthing.${DOMAIN}
			 				export SYNCTHING_FQDN
						fi

					echo -e "${CGREEN}${CEND}"
					echo -e "${CCYAN}Sous domaine de Jackett${CEND}"
					read -rp "JACKETT_FQDN = " JACKETT_FQDN

						if [ -n "$JACKETT_FQDN" ]
						then
			 				export JACKETT_FQDN=${JACKETT_FQDN}.${DOMAIN}
						else
			 				JACKETT_FQDN=jackett.${DOMAIN}
			 				export JACKETT_FQDN
						fi

					echo -e "${CGREEN}${CEND}"
					echo -e "${CCYAN}Sous domaine de lidarr${CEND}"
					read -rp "LIDARR_FQDN = " LIDARR_FQDN

						if [ -n "$LIDARR_FQDN" ]
						then
			 				export LIDARR_FQDN=${LIDARR_FQDN}.${DOMAIN}
						else
			 				LIDARR_FQDN=lidarr.${DOMAIN}
			 				export LIDARR_FQDN
						fi

					echo -e "${CGREEN}${CEND}"
					echo -e "${CCYAN}Sous domaine de portainer${CEND}"
					read -rp "PORTAINER_FQDN = " PORTAINER_FQDN

						if [ -n "$PORTAINER_FQDN" ]
						then
			 				export PORTAINER_FQDN=${PORTAINER_FQDN}.${DOMAIN}
						else
			 				PORTAINER_FQDN=portainer.${DOMAIN}
			 				export PORTAINER_FQDN
						fi

					echo -e "${CGREEN}${CEND}"
					echo -e "${CCYAN}Sous domaine de Tautulli${CEND}"
					read -rp "TAUTULLI_FQDN = " TAUTULLI_FQDN

						if [ -n "$TAUTULLI_FQDN" ]
						then
			 				export TAUTULLI_FQDN=${TAUTULLI_FQDN}.${DOMAIN}
						else
			 				TAUTULLI_FQDN=tautulli.${DOMAIN}
			 				export TAUTULLI_FQDN
						fi


					echo -e "${CGREEN}${CEND}"
					echo -e "${CCYAN}Sous domaine de nextcloud${CEND}"
					read -rp "NEXTCLOUD_FQDN = " NEXTCLOUD_FQDN

						if [ -n "$NEXTCLOUD_FQDN" ]
						then
			 				export NEXTCLOUD_FQDN=${NEXTCLOUD_FQDN}.${DOMAIN}
						else
			 				NEXTCLOUD_FQDN=nextcloud.${DOMAIN}
			 				export NEXTCLOUD_FQDN
						fi

					echo -e "${CGREEN}${CEND}"
					echo -e "${CCYAN}Sous domaine de heimdall${CEND}"
					read -rp "HEIMDALL_FQDN = " HEIMDALL_FQDN

						if [ -n "$HEIMDALL_FQDN" ]
						then
			 				export HEIMDALL_FQDN=${HEIMDALL_FQDN}.${DOMAIN}
						else
			 				HEIMDALL_FQDN=heimdall.${DOMAIN}
			 				export HEIMDALL_FQDN
						fi

				fi

			## Création d'un fichier .env
			docker network create traefik_proxy 2>/dev/null
			docker network create torrent 2>/dev/null


			export PROXY_NETWORK=traefik_proxy
			export TRAEFIK_DASHBOARD_URL=traefik.${DOMAIN}
			export PLEX_FQDN=plex.${DOMAIN}
			export PYLOAD_FQDN=pyload.${DOMAIN}
			export MEDUSA_FQDN=medusa.${DOMAIN}
			export RTORRENT_FQDN=rtorrent.${DOMAIN}
			export RADARR_FQDN=radarr.${DOMAIN}
			export SYNCTHING_FQDN=syncthing.${DOMAIN}
			export JACKETT_FQDN=jackett.${DOMAIN}
			export LIDARR_FQDN=lidarr.${DOMAIN}
			export PORTAINER_FQDN=portainer.${DOMAIN}
			export TAUTULLI_FQDN=tautulli.${DOMAIN}
			export NEXTCLOUD_FQDN=nextcloud.${DOMAIN}
			export HEIMDALL_FQDN=heimdall.${DOMAIN}

			cat <<- EOF > /mnt/.env
			FILMS=$FILMS
			SERIES=$SERIES
			ANIMES=$ANIMES
			MUSIC=$MUSIC
			VOLUMES_ROOT_PATH=$VOLUMES_ROOT_PATH
			VAR=$VAR
			MAIL=$MAIL
			USERNAME=$USERNAME
			DOMAIN=$DOMAIN
			PASS=$PASS
			PROXY_NETWORK=$PROXY_NETWORK
			TRAEFIK_DASHBOARD_URL=$TRAEFIK_DASHBOARD_URL
			PLEX_FQDN=$PLEX_FQDN
			LIDARR_FQDN=$LIDARR_FQDN
			MEDUSA_FQDN=$MEDUSA_FQDN
			RTORRENT_FQDN=$RTORRENT_FQDN
			RADARR_FQDN=$RADARR_FQDN
			PORTAINER_FQDN=$PORTAINER_FQDN
			JACKETT_FQDN=$JACKETT_FQDN
			NEXTCLOUD_FQDN=$NEXTCLOUD_FQDN
			TAUTULLI_FQDN=$TAUTULLI_FQDN
			SYNCTHING_FQDN=$SYNCTHING_FQDN
			PYLOAD_FQDN=$PYLOAD_FQDN
			HEIMDALL_FQDN=$HEIMDALL_FQDN

			EOF

			## Création d'un fichier traefik.toml
			mkdir -p ${VOLUMES_ROOT_PATH}/traefik
			cat <<- EOF > ${VOLUMES_ROOT_PATH}/traefik/traefik.toml
			defaultEntryPoints = ["https","http"]
			InsecureSkipVerify = true

			[api]
			entryPoint = "traefik"
			dashboard = true

			[entryPoints]
			  [entryPoints.http]
			  address = ":80"
			    [entryPoints.http.redirect]
			    entryPoint = "https"
			  [entryPoints.https]
			  address = ":443"
			    [entryPoints.https.tls]
			    minVersion = "VersionTLS12"
			    cipherSuites = [
			      "TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305",
			      "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384",
			      "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256",
			      "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256",
			      "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA",
			      "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA"
			    ]
			  [entryPoints.traefik]
			  address = ":8080"

			[acme]
			email = "${MAIL}"
			storage = "/etc/traefik/acme/acme.json"
			entryPoint = "https"
			onHostRule = true
			onDemand = false
			  [acme.httpChallenge]
			  entryPoint = "http"

			[docker]
			endpoint = "unix:///var/run/docker.sock"
			domain = "${DOMAIN}"
			watch = true
			exposedbydefault = false
			EOF
						
			## creation du docker-compose personnalisé dans lequel viendront s'incrémenter les variables du fichier .envt
			cat <<- EOF > /mnt/docker-compose.yml
			version: '3'
			services:

			  traefik:
			    image: traefik
			    container_name: traefik
			    restart: unless-stopped
			    hostname: traefik
			    labels:
			      - traefik.enable=true
			      - traefik.frontend.rule=Host:${TRAEFIK_DASHBOARD_URL}
			      - traefik.port=8080
			      - traefik.docker.network=${PROXY_NETWORK}
			      - traefik.frontend.auth.basic=${VAR}
			    volumes:
			      - /var/run/docker.sock:/var/run/docker.sock:ro  
			      - ${VOLUMES_ROOT_PATH}/traefik/traefik.toml:/traefik.toml:ro
			      - ${VOLUMES_ROOT_PATH}/letsencrypt/certs:/etc/traefik/acme:rw
			      - /var/log/traefik:/var/log
			    ports:
			      - "80:80"
			      - "443:443"
			    networks:
			      - proxy
			    command:
			      - --web
			      - --accessLog.filePath=/var/log/access.log
			      - --accessLog.filters.statusCodes=400-499

			  plex:
			    container_name: plex
			    image: plexinc/pms-docker
			    restart: unless-stopped
			    hostname: plex
			    labels:
			      - traefik.enable=true
			      - traefik.frontend.rule=Host:${PLEX_FQDN}
			      - traefik.port=32400
			      - traefik.docker.network=${PROXY_NETWORK}
			    environment:
			      - TZ=Europe/Paris
			      - PLEX_CLAIM=
			      - PLEX_UID=0
			      - PLEX_GID=0
			    ports:
			      - 32400:32400
			    volumes:
			      - ${VOLUMES_ROOT_PATH}/Medias:/mnt
			      - ${VOLUMES_ROOT_PATH}/plex/config:/config
			      - /dev/shm:/transcode
			    networks:
			      - proxy

			  lidarr:
			    container_name: lidarr
			    image: linuxserver/lidarr
			    restart: unless-stopped
			    hostname: lidarr
			    labels:
			      - traefik.enable=true
			      - traefik.frontend.rule=Host:${LIDARR_FQDN}
			      - traefik.port=8686
			      - traefik.docker.network=${PROXY_NETWORK}
			      - traefik.frontend.auth.basic=${VAR}
			    volumes:
			      - ${VOLUMES_ROOT_PATH}/Medias/${MUSIC}:/music:rw
			      - ${VOLUMES_ROOT_PATH}/lidarr/config:/config
			      - ${VOLUMES_ROOT_PATH}/rutorrent/downloads:/downloads
			    environment:
			      - /etc/localtime:/etc/localtime:ro
			      - TZ=Paris/Europe
			      - PUID=0
			      - PGID=0
			    networks:
			      - proxy

			  pyload:
			    container_name: pyload
			    image: writl/pyload
			    restart: unless-stopped
			    hostname: pyload
			    labels:
			      - traefik.enable=true
			      - traefik.frontend.rule=Host:${PYLOAD_FQDN}
			      - traefik.port=8000
			      - traefik.docker.network=${PROXY_NETWORK}
			      - traefik.frontend.auth.basic=${VAR}
			    environment:
			      - /etc/localtime:/etc/localtime:ro
			      - TZ=Paris/Europe
			      - PUID=0
			      - PGID=0
			    volumes:
			      - ${VOLUMES_ROOT_PATH}/pyload/download:/opt/pyload/Downloads:rw
			      - ${VOLUMES_ROOT_PATH}/pyload/config:/opt/pyload/pyload-config:rw
			    networks:
			      - proxy

			  radarr:
			    container_name: radarr
			    image: linuxserver/radarr
			    restart: unless-stopped
			    hostname: radarr
			    labels:
			      - traefik.enable=true
			      - traefik.frontend.rule=Host:${RADARR_FQDN}
			      - traefik.port=7878
			      - traefik.docker.network=${PROXY_NETWORK}
			      - traefik.frontend.auth.basic=${VAR}
			    environment:
			      - /etc/localtime:/etc/localtime:ro
			      - TZ=Paris/Europe
			      - PUID=0
			      - PGID=0
			    volumes:
			      - ${VOLUMES_ROOT_PATH}/radarr/config:/config
			      - ${VOLUMES_ROOT_PATH}/rutorrent/downloads:/downloads
			      - ${VOLUMES_ROOT_PATH}/Medias/${FILMS}:/movies
			    networks:
			      - proxy

			  syncthing:
			    image: linuxserver/syncthing
			    container_name: syncthing
			    restart: unless-stopped
			    hostname: watcher
			    labels:
			      - traefik.enable=true
			      - traefik.frontend.rule=Host:${SYNCTHING_FQDN}
			      - traefik.port=8384
			      - traefik.docker.network=${PROXY_NETWORK}
			      - traefik.frontend.auth.basic=${VAR}
			    volumes:
			      - ${VOLUMES_ROOT_PATH}/syncthing/config:/config
			      - ${VOLUMES_ROOT_PATH}/syncthing/data:/mnt/data
			    ports:
			      - 22000:22000
			      - 21027:21027/udp
			    environment:
			      - UMASK_SET=022
			      - /etc/localtime:/etc/localtime:ro
			      - TZ=Paris/Europe
			      - PUID=0
			      - PGID=0
			    networks:
			      - proxy

			  medusa:
			    image: linuxserver/medusa
			    container_name: medusa
			    restart: unless-stopped
			    hostname: medusa
			    labels:
			      - traefik.enable=true
			      - traefik.frontend.rule=Host:${MEDUSA_FQDN}
			      - traefik.port=8081
			      - traefik.docker.network=${PROXY_NETWORK}
			      - traefik.frontend.auth.basic=${VAR}
			    volumes:
			      - ${VOLUMES_ROOT_PATH}/Medias/${SERIES}:/tv
			      - ${VOLUMES_ROOT_PATH}/rutorrent/downloads:/downloads
			      - ${VOLUMES_ROOT_PATH}/medusa/config:/config
			    environment:
			      - /etc/localtime:/etc/localtime:ro
			      - TZ=Paris/Europe
			      - PUID=0
			      - PGID=0
			    networks:
			      - proxy
				  
			  torrent:
			    container_name: torrent
			    image: xataz/rtorrent-rutorrent:filebot
			    restart: unless-stopped
			    hostname: torrent
			    labels:
			      - traefik.enable=true
			      - traefik.frontend.rule=Host:${RTORRENT_FQDN}
			      - traefik.port=8080
			      - traefik.docker.network=${PROXY_NETWORK}
			      - traefik.frontend.auth.basic=${VAR}
			    environment:
			      - FILEBOT_RENAME_METHOD=copy
			      - FILEBOT_RENAME_MOVIES={n} ({y})/{n} ({y})
			      - FILEBOT_RENAME_SERIES={n}/Saison {s}/{n} - {s00e00} - {t}
			      - UID=1001
			      - GID=1001
			      - DHT_RTORRENT=on
			      - PORT_RTORRENT=6881
			    volumes:
			      - ${VOLUMES_ROOT_PATH}/rutorrent/downloads:/data/torrents
			      - ${VOLUMES_ROOT_PATH}/Medias:/data/Media
			      - ${VOLUMES_ROOT_PATH}/rutorrent/data:/data
			      - ${VOLUMES_ROOT_PATH}/rutorrent/config:/config
			    networks:
			      - torrent
			      - proxy

			  jackett:
			    container_name: jackett
			    image: xataz/jackett
			    restart: unless-stopped
			    hostname: jackett
			    labels:
			      - traefik.enable=true
			      - traefik.frontend.rule=Host:${JACKETT_FQDN}
			      - traefik.port=9117
			      - traefik.docker.network=${PROXY_NETWORK}
			      - traefik.frontend.auth.basic=${VAR}
			    environment:
			      - TZ=Paris/Europe
			      - PUID=0
			      - PGID=0
			    volumes:
			      - ${VOLUMES_ROOT_PATH}/Jackett/config:/config
			      - ${VOLUMES_ROOT_PATH}/Jackett/downloads:/downloads
			    networks:
			      - proxy

			  portainer:
			    container_name: portainer
			    image: portainer/portainer
			    restart: unless-stopped
			    hostname: portainer
			    labels:
			      - traefik.enable=true
			      - traefik.frontend.rule=Host:${PORTAINER_FQDN}
			      - traefik.port=9000
			      - traefik.docker.network=${PROXY_NETWORK}
			      - traefik.frontend.auth.basic=${VAR}
			    volumes:
			      - ${VOLUMES_ROOT_PATH}/portainer/data:/data
			      - /var/run/docker.sock:/var/run/docker.sock
			    networks:
			      - proxy

			  tautulli:
			    container_name: tautulli
			    image: tautulli/tautulli
			    restart: unless-stopped
			    hostname: tautulli
			    labels:
			      - traefik.enable=true
			      - traefik.frontend.rule=Host:${TAUTULLI_FQDN}
			      - traefik.port=8181
			      - traefik.docker.network=${PROXY_NETWORK}
			      - traefik.frontend.auth.basic=${VAR}
			    environment:
			      - TZ=Paris/Europe
			      - PUID=0
			      - PGID=0
			    volumes:
			      - ${VOLUMES_ROOT_PATH}/tautulli/config:/config
			      - ${VOLUMES_ROOT_PATH}/plex/config/Library/Application Support/Plex Media Server/Logs:/logs:ro
			    networks:
			      - proxy

			  heimdall:
			    container_name: heimdall
			    image: linuxserver/heimdall
			    restart: unless-stopped
			    hostname: heimdall
			    labels:
			      - traefik.enable=true
			      - traefik.frontend.rule=Host:${HEIMDALL_FQDN}
			      - traefik.port=443
			      - traefik.docker.network=${PROXY_NETWORK}
			      - traefik.frontend.auth.basic=${VAR}
			      - traefik.protocol=https
			    environment:
			      - TZ=Paris/Europe
			      - PUID=1001
			      - PGID=1001
			    volumes:
			      - ${VOLUMES_ROOT_PATH}/heimdall/config:/config
			    networks:
			      - proxy

			  nextcloud:
			    container_name: nextcloud
			    image: nextcloud
			    volumes:
			      - ${VOLUMES_ROOT_PATH}/nextcloud:/var/www/html
			    labels:
			      - traefik.backend=nextcloud
			      - traefik.port=80
			      - traefik.frontend.rule=Host:${NEXTCLOUD_FQDN}
			      - traefik.enable=true
			      - traefik.docker.network=traefik_proxy
			      - traefik.frontend.auth.basic=${VAR}
			    depends_on:
			      - mariadb
			    networks:
			      - proxy
			      - internal

			  mariadb:
			    image: mariadb
			    container_name: mariadb
			    environment:
			      - MYSQL_USER=nextcloud
			      - MYSQL_PASSWORD=${PASS}
			      - MYSQL_DATABASE=nextcloud
			      - MYSQL_RANDOM_ROOT_PASSWORD=yes
			    volumes:
			      - ${VOLUMES_ROOT_PATH}/mariadb:/var/lib/mysql
			    networks:
			      - internal
			    labels:
			      - traefik.enable=false

			networks:
			  torrent:
			  proxy:
			    external:
			      name: ${PROXY_NETWORK}
			  internal:
			    external: false
			EOF

			clear
			echo -e "${CCYAN}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			echo -e "${CCYAN}					VERIFICATION DE LA CONFORMITE DU DOCKER-COMPOSE					  ${CEND}"
			echo -e "${CCYAN}-------------------------------------------------------------------------------------------------------------------------${CEND}"
			read -p "Appuyer sur la touche Entrer pour continuer"
			nano /mnt/docker-compose.yml
			progress-bar 20
			cd /mnt
			docker-compose up -d traefik 2>/dev/null
			echo ""
			echo -e "${CCYAN}La configuration des variables s'est parfaitement déroulée ${CEND}"
			echo ""
			read -p "Appuyer sur la touche Entrer pour continuer"
			seedbox.sh
		;;


		3)
			clear
			logo.sh	
			export $(xargs </mnt/.env)
			cd /mnt
			APPLI=""
			sortir=false
			while [ !sortir ]
			do
			echo ""
			echo -e "${CRED}-----------------${CEND}"
			echo -e "${CCYAN}  APPLICATIONS  ${CEND}"
			echo -e "${CRED}-----------------${CEND}"
			echo ""
			echo -e "${CGREEN}   1) Plex ${CEND}"
			echo -e "${CGREEN}   2) Rtorrent ${CEND}"
			echo -e "${CGREEN}   3) Radarr ${CEND}"
			echo -e "${CGREEN}   4) Lidarr ${CEND}"
			echo -e "${CGREEN}   5) Medusa ${CEND}"
			echo -e "${CGREEN}   6) Pyload ${CEND}"
			echo -e "${CGREEN}   7) Syncthing ${CEND}"
			echo -e "${CGREEN}   8) Jackett ${CEND}"
			echo -e "${CGREEN}   9) Portainer ${CEND}"
			echo -e "${CGREEN}   10) Tautulli ${CEND}"
			echo -e "${CGREEN}   11) Heimball ${CEND}"
			echo -e "${CGREEN}   12) Nextcloud ${CEND}"
			echo -e "${CGREEN}   13) Retour Menu Principal ${CEND}"
			echo ""
			read -p "Appli choix [1-13]: " -e -i 1 APPLI
			echo ""			
			case $APPLI in
				1)
				if ps -e | grep -q Plex; then
					echo -e "${CGREEN}Plex est déjà lancé${CEND}"
					echo ""
					read -p "Appuyer sur la touche Entrer pour retourner au menu"
					clear
					logo.sh
				else
					# CLAIM pour Plex
					echo ""
					echo -e "${CCYAN}Un token est nécéssaire pour AUTHENTIFIER le serveur Plex ${CEND}"
					echo -e "${CCYAN}Pour obtenir un identifiant CLAIM, allez à cette adresse et copier le dans le terminal ${CEND}"
					echo -e "${CRED}https://www.plex.tv/claim/ ${CEND}"
					echo ""
					read -rp "CLAIM = " CLAIM

					if [ -n "$CLAIM" ]
					then
						sed -i -e "s/PLEX_CLAIM=/PLEX_CLAIM=${CLAIM}/g" /mnt/docker-compose.yml
					fi

					## Lancement de Plex
					docker-compose up -d plex 2>/dev/null
					echo ""
					progress-bar 20
					echo ""
					echo -e "${CGREEN}Installation de Plex réussie${CEND}"
					echo ""
					read -p "Appuyer sur la touche Entrer pour continuer"
					clear
					logo.sh
				fi

				;;

				2)
				if docker ps -a | grep -q torrent; then
					echo -e "${CGREEN}rtorrent est déjà lancé${CEND}"
					echo ""
					read -p "Appuyer sur la touche Entrer pour retourner au menu"
					clear
					logo.sh
				else
					export $(xargs </mnt/.env)
					docker-compose up -d torrent
					progress-bar 20
					echo ""
					echo -e "${CGREEN}Installation de Rtorrent réussie${CEND}"
					echo ""

					# Configuration pour le téléchargement en manuel avec filebot
					docker exec -t torrent rm -rf /data/Media/*
					rm -rf $VOLUMES_ROOT_PATH/Medias/*
					docker exec -t torrent mkdir -p /data/Media/${FILMS}
					docker exec -t torrent mkdir -p /data/Media/${SERIES}
					docker exec -t torrent mkdir -p /data/Media/${MUSIC}
					docker exec -t torrent mkdir -p /data/Media/${ANIMES}
					docker exec -t torrent sed -i -e "s/Movies/${FILMS}/g" /usr/local/bin/postdl
					docker exec -t torrent sed -i -e "s/TV/${SERIES}/g" /usr/local/bin/postdl
					docker exec -t torrent sed -i -e "s/Music/${MUSIC}/g" /usr/local/bin/postdl
					docker exec -t torrent sed -i -e "s/Animes/${ANIMES}/g" /usr/local/bin/postdl
					docker exec -t torrent sed -i '/*)/,/;;/d' /usr/local/bin/postdl
					docker exec -t torrent chown -R 1001:1001 /mnt
					read -p "Appuyer sur la touche Entrer pour continuer"
					clear
					logo.sh
				fi

				;;

				3)

				if docker ps -a | grep -q radarr; then
					echo -e "${CGREEN}Radarr est déjà lancé${CEND}"
					echo ""
					read -p "Appuyer sur la touche Entrer pour retourner au menu"
					clear
					logo.sh
				else
					docker-compose up -d radarr 2>/dev/null
					progress-bar 20
					echo ""
					echo -e "${CGREEN}Installation de radarr réussie${CEND}"
					echo ""
					read -p "Appuyer sur la touche Entrer pour continuer"
					clear
					logo.sh
				fi

				;;

				4)

				if docker ps -a | grep -q lidarr; then
					echo -e "${CGREEN}Lidarr est déjà lancé${CEND}"
					echo ""
					read -p "Appuyer sur la touche Entrer pour retourner au menu"
					clear
					logo.sh
				else
					docker-compose up -d lidarr 2>/dev/null
					progress-bar 20
					echo ""
					echo -e "${CGREEN}Installation de lidarr réussie${CEND}"
					echo ""
					read -p "Appuyer sur la touche Entrer pour continuer"
					clear
					logo.sh
				fi

				;;


				5)
				if docker ps -a | grep -q medusa; then
					echo -e "${CGREEN}Medusa est déjà lancé${CEND}"
					echo ""
					read -p "Appuyer sur la touche Entrer pour retourner au menu"
					clear
					logo.sh
				else
					docker-compose up -d medusa 2>/dev/null
					progress-bar 20
					echo ""
					echo -e "${CGREEN}Installation de medusa réussie${CEND}"
					echo ""
					read -p "Appuyer sur la touche Entrer pour continuer"
					clear
					logo.sh
				fi

				;;

				6)
				if docker ps -a | grep -q pyload; then
					echo -e "${CGREEN}Pyload est déjà lancé${CEND}"
					echo ""
					read -p "Appuyer sur la touche Entrer pour retourner au menu"
					clear
					logo.sh
				else
					docker-compose up -d pyload 2>/dev/null
					progress-bar 20
					echo ""
					echo -e "${CGREEN}Installation de pyload réussie${CEND}"
					echo ""
					read -p "Appuyer sur la touche Entrer pour continuer"
					clear
					logo.sh
				fi

				;;

				7)
				if docker ps -a | grep -q syncthing; then
					echo -e "${CGREEN}Syncthing est déjà lancé${CEND}"
					echo ""
					read -p "Appuyer sur la touche Entrer pour retourner au menu"
					clear
					logo.sh
				else
					docker-compose up -d syncthing 2>/dev/null
					progress-bar 20
					echo ""
					echo -e "${CGREEN}Installation de syncthing réussie${CEND}"
					echo ""
					read -p "Appuyer sur la touche Entrer pour continuer"
					clear
					logo.sh
				fi

				;;

				8)
				if docker ps -a | grep -q jackett; then
					echo -e "${CGREEN}Jackett est déjà lancé${CEND}"
					echo ""
					read -p "Appuyer sur la touche Entrer pour retourner au menu"
					clear
					logo.sh
				else
					docker-compose up -d jackett 2>/dev/null
					progress-bar 20
					echo ""
					echo -e "${CGREEN}Installation de Jackett réussie${CEND}"
					echo ""
					read -p "Appuyer sur la touche Entrer pour continuer"
					clear
					logo.sh
				fi

				;;

				9)
				if docker ps -a | grep -q portainer; then
					echo -e "${CGREEN}Ombi est déjà lancé${CEND}"
					echo ""
					read -p "Appuyer sur la touche Entrer pour retourner au menu"
					clear
					logo.sh
				else
					docker-compose up -d portainer 2>/dev/null
					progress-bar 20
					echo ""
					echo -e "${CGREEN}Installation de portainer réussie${CEND}"
					echo ""
					read -p "Appuyer sur la touche Entrer pour continuer"
					clear
					logo.sh
				fi

				;;

				10)
				if docker ps -a | grep -q tautulli; then
					echo -e "${CGREEN}Tautulli est déjà lancé${CEND}"
					echo ""
					read -p "Appuyer sur la touche Entrer pour retourner au menu"
					clear
					logo.sh
				else
					docker-compose up -d tautulli 2>/dev/null
					progress-bar 20
					echo ""
					echo -e "${CGREEN}Installation de Tautulli réussie${CEND}"
					echo ""
					read -p "Appuyer sur la touche Entrer pour continuer"
					clear
					logo.sh
				fi

				;;

				11)
				if docker ps -a | grep -q heimdall; then
					echo -e "${CGREEN}Heimdall est déjà lancé${CEND}"
					echo ""
					read -p "Appuyer sur la touche Entrer pour retourner au menu"
					clear
					logo.sh
				else
					docker-compose up -d heimdall 2>/dev/null
					progress-bar 20
					echo ""
					echo -e "${CGREEN}Installation de heimdall réussie${CEND}"
					echo ""
					read -p "Appuyer sur la touche Entrer pour continuer"
					clear
					logo.sh
				fi

				;;

				12)
				if docker ps -a | grep -q nextcloud; then
					echo -e "${CGREEN}Nextcloud est déjà lancé${CEND}"
					echo ""
					read -p "Appuyer sur la touche Entrer pour retourner au menu"
					clear
					logo.sh
				else
					docker-compose up -d nextcloud 2>/dev/null
					progress-bar 20
					echo ""
					echo -e "${CGREEN}Installation de nextcloud réussie${CEND}"
				
				echo ""
				echo -e "${CRED}---------------------------------------------------------${CEND}"
				echo -e "${CCYAN}       Paramètre de connection Nextcloud		 ${CEND}"
				echo -e "${CCYAN}							 ${CEND}"
				echo -e "${CRED}---------------------------------------------------------${CEND}"
				echo -e "${CGREEN}    	- identifiants (Ce que vous voulez)		 ${CEND}"
				echo -e "${CGREEN}    	- Utilisateur base de donnée: nextcloud		 ${CEND}"
				echo -e "${CGREEN}    	- passwd: $PASS					 ${CEND}"
				echo -e "${CGREEN}    	- Nom de la base de donnée: nextcloud		 ${CEND}"
				echo -e "${CGREEN}    	- hote: mariadb					 ${CEND}"
				echo -e "${CRED}---------------------------------------------------------${CEND}"
				echo -e "${CCYAN}       Ne pas oublier de choisir mysql/mariadb		 ${CEND}"
				echo -e "${CRED}---------------------------------------------------------${CEND}"
				echo ""
				read -p "Appuyer sur la touche Entrer pour continuer"
				clear
				logo.sh
				
				fi

				;;

				13)
				sortir=true
				seedbox.sh

				;;

			esac
			done

		;;

		4)
		clear
		logo.sh
		OUTIL=""
		sortir=false
		while [ !sortir ]
		do
		echo ""
		echo -e "${CRED}--------------------------------${CEND}"
		echo -e "${CCYAN}    SECURISER LA SEEDBOX	${CEND}"
		echo -e "${CRED}--------------------------------${CEND}"
		echo ""
		echo -e "${CGREEN}   1) Changer le passwd de root ${CEND}"
		echo -e "${CGREEN}   2) Modifier l'utilisateur pour l'authentification web${CEND}"
		echo -e "${CGREEN}   3) Modification du port ssh && Mise en place serveur mail${CEND}"
		echo -e "${CGREEN}   4) Configuration Fail2ban && Portsentry && Iptables${CEND}"

		echo -e ""
			read -p "Outil choix [1-4]: " -e -i 1 OUTIL
			echo ""			
			case $OUTIL in
			
				1) # Changer le passwd de root dans putty
				clear
				logo.sh
				echo ""
				echo -e "${CCYAN}Cette étape permet de changer le passwd de root ${CEND}"
				echo ""
				passwd root
				echo ""
				echo -e "${CCYAN}Le passwd a été modifié avec succés ${CEND}"
				echo ""
				read -p "Appuyer sur la touche Entrer pour continuer"
				clear
				logo.sh
				
				;;

				2) # Changer l'identification des applis docker
				export $(xargs </mnt/.env)
				clear
				logo.sh
				echo ""
				echo -e "${CCYAN}Cette étape permet de changer l'identification de vos applis docker ${CEND}"
				echo ""
				read -rp "Taper le nom de l'utilisateur " USER
				PASSWD=$(htpasswd -c /etc/apache2/.htpasswd $USER 2>/dev/null)
				PASSWD=$(sed -e 's/\$/\$$/g' /etc/apache2/.htpasswd 2>/dev/null)
				sed -i -e "s|traefik.frontend.auth.basic=.*|traefik.frontend.auth.basic=$PASSWD|g" /mnt/docker-compose.yml

				# On relance les containers actifs pour prendre en compte les modifs apportées au docker-compose && recréation de la configuration filebot
				cd /mnt
				var=$(docker-compose ps --filter names | awk {'print $1'} | sed '1,2d')
				docker-compose up -d $var
				progress-bar 20
				echo ""
				echo -e "${CGREEN}Paramètres d'identification mis à jour avec succès${CEND}"
				echo ""

				# Configuration pour le téléchargement en manuel avec filebot
				docker exec -t torrent rm -rf /data/Media/*
				rm -rf $VOLUMES_ROOT_PATH/Medias/*
				docker exec -t torrent mkdir -p /data/Media/${FILMS}
				docker exec -t torrent mkdir -p /data/Media/${SERIES}
				docker exec -t torrent mkdir -p /data/Media/${MUSIC}
				docker exec -t torrent mkdir -p /data/Media/${ANIMES}
				docker exec -t torrent sed -i -e "s/Movies/${FILMS}/g" /usr/local/bin/postdl
				docker exec -t torrent sed -i -e "s/TV/${SERIES}/g" /usr/local/bin/postdl
				docker exec -t torrent sed -i -e "s/Music/${MUSIC}/g" /usr/local/bin/postdl
				docker exec -t torrent sed -i -e "s/Animes/${ANIMES}/g" /usr/local/bin/postdl
				docker exec -t torrent sed -i '/*)/,/;;/d' /usr/local/bin/postdl
				docker exec -t torrent chown -R 1001:1001 /mnt
				read -p "Appuyer sur la touche Entrer pour continuer"
				clear
				logo.sh

				;;
		
				3) # Modification du port ssh et mise en place serveur mail

				## Configuration postfix pour les mails
				export $(xargs </mnt/.env)
				HOST=$(hostname)
				IP=$(curl ifconfig.me)
				echo "$IP" "$HOST.$DOMAIN" "$HOST" >> /etc/hosts
				echo ""
				echo -e "${CCYAN}Mise en place du serveur Mail${CEND}"
				echo ""
				echo -e "${CCYAN}-------------------------------------------------------------------------------------------------------------------------${CEND}"
				echo -e "${CCYAN}					PRECISONS IMPORTANTES								  ${CEND}"
				echo -e "${CCYAN}-------------------------------------------------------------------------------------------------------------------------${CEND}"
				echo -e "${CGREEN}		DECLARER LE HOSTNAME AUPRES DU REGISTRAR (enregistrement A pointant sur l'ip)				  ${CEND}"	
				echo -e "${CGREEN}		Pour trouver le hostname taper "hostname" en ligne de commande						  ${CEND}"
				echo -e "${CRED}--------------------------------------------------------------------------------------------------------------------------${CEND}"
				echo -e "${CCYAN}															  ${CEND}"
				echo -e "${CCYAN}		Installation postfix : laisser SITE INTERNET par default						  ${CEND}"
				echo -e "${CCYAN}				       Nom de courrier: taper l'hostname trouvé précédement				  ${CEND}"
				echo -e "${CCYAN}-------------------------------------------------------------------------------------------------------------------------${CEND}"
				echo -e "${CGREEN}${CEND}"
				read -p "Appuyer sur la touche Entrer pour continuer"
				apt install -f postfix mailutils logwatch -y
				echo "root: $MAIL" >> /etc/aliases
				newaliases
				echo "echo 'Acces Shell Root le ' \`date\` \`who\` | mail -s 'Connexion serveur via root' root" >> /root/.bashrc
				service postfix restart
				sed -i -e 's/Output = stdout/Output = mail/g' /usr/share/logwatch/default.conf/logwatch.conf
				cat <<- EOF > /usr/share/logwatch/default.conf/logfiles/traefik.conf

				########################################################
				# Define log file group for nginx
				########################################################

				# What actual file? Defaults to LogPath if not absolute path….
				LogFile = traefik/*access.log

				# If the archives are searched, here is one or more line
				# (optionally containing wildcards) that tell where they are…
				#If you use a “-” in naming add that as well -mgt
				Archive = traefik/*access.log*


				# Expand the repeats (actually just removes them now)
				*ExpandRepeats

				# Keep only the lines in the proper date range…
				*ApplyhttpDate

				# vi: shiftwidth=3 tabstop=3
				EOF

				cp /usr/share/logwatch/default.conf/services/http.conf /usr/share/logwatch/default.conf/services/traefik.conf
				sed -i -e 's/httpd/traefik/g' /usr/share/logwatch/default.conf/services/traefik.conf
				sed -i -e 's/http/traefik/g' /usr/share/logwatch/default.conf/services/traefik.conf
				echo ""
				cp /usr/share/logwatch/scripts/services/http /usr/share/logwatch/scripts/services/traefik
				logwatch restart
				echo -e "${CCYAN}Le serveur Mail est configuré avec succés Mail${CEND}"
				echo""
				read -p "Appuyer sur la touche Entrer pour continuer"
				echo ""

				## configuration ssh
				read -rp "Choisir un nom d'utilisateur " NAME
				mkdir /home/$NAME
				useradd -s /bin/bash $NAME
				echo ""
				echo -e "${CCYAN}Définir un mot de passe utilisateur${CEND}"
				passwd $NAME
				chown -R $NAME:$NAME /home/$NAME
				cat <<- EOF >> /etc/ssh/sshd_config
				AllowUsers $NAME
				EOF
				echo ""
				read -rp "Choisir un port ssh (Entre 22 et 65 536) " PORT
				sed -i -e "s/#Port/Port/g" /etc/ssh/sshd_config
				sed -i -e "s/Port 22/Port $PORT/g" /etc/ssh/sshd_config
				#sed -i '/Port/d' /etc/ssh/sshd_config
				#echo "Port $PORT" >> /etc/ssh/sshd_config
				sed -i -e "s/PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config
				echo ""
				progress-bar 20
				echo ""
				service sshd restart

				echo -e "${CCYAN}Le port ssh a été changé avec succés${CEND}"
				echo ""
				echo -e "${CRED}---------------------------------------------------------${CEND}"
				echo -e "${CCYAN}    La connection root est maintenant désactivée        ${CEND}"
				echo -e "${CCYAN}    Nouveaux paramètres de connection:		         ${CEND}"
				echo -e "${CRED}---------------------------------------------------------${CEND}"
				echo -e "${CGREEN}    	- port: $PORT				         ${CEND}"
				echo -e "${CGREEN}    	- username: $NAME			         ${CEND}"
				echo -e "${CGREEN}    	- passwd: mot de passe créé précédemment         ${CEND}"
				echo -e "${CRED}---------------------------------------------------------${CEND}"
				echo -e "${CCYAN}    Pour passer en root, taper su + mot de passe root	 ${CEND}"
				echo -e "${CRED}---------------------------------------------------------${CEND}"
				echo ""
				read -p "Appuyer sur la touche Entrer pour continuer"
				clear
				logo.sh

				;;

				4) # Installation Fail2ban et portsentry
				export $(xargs </mnt/.env)
				apt install fail2ban portsentry -y
				echo ""
				read -rp "Quel est votre port ssh ? " PORT
				echo "" 

				# Récupération ip serveur et ip domicile
				IP_DOM=$(grep 'Accepted' /var/log/auth.log | cut -d ' ' -f11 | head -1)
				IP_SERV=$(hostname -I)

				# Jail ssh
				cat <<- EOF > /etc/fail2ban/jail.d/custom.conf
				[DEFAULT]
				ignoreip = 127.0.0.1 $IP_DOM
				findtime = 3600
				bantime = 600
				maxretry = 3

				[sshd]
				enabled = true
				port = $PORT
				logpath = /var/log/auth.log
				banaction = iptables-multiport
				maxretry = 5
				EOF
				
				# Jail traefik
				cat <<- EOF > /etc/fail2ban/jail.d/traefik.conf
				[DEFAULT]
				ignoreip = 127.0.0.1 $IP_DOM
				findtime = 3600
				bantime = 600
				maxretry = 3
				banaction = docker-action

				[traefik-auth]
				enabled = true
				logpath = /var/log/traefik/access.log
				port = http,https
				maxretry = 2

				[traefik-botsearch]
				enabled = true
				logpath = /var/log/traefik/access.log
				maxretry = 1
				port = http,https

				[traefik-badbots]
				enabled = true
				filter = apache-badbots
				logpath = /var/log/traefik/access.log
				maxretry = 1
				port = http,https
				EOF

				# Regex traefik
				cat <<- EOF > /etc/fail2ban/filter.d/traefik-auth.conf
				[Definition]
				failregex = ^<HOST> \- \S+ \[\] \"(GET|POST|HEAD) .+\" 401 .+$
				ignoreregex =
				EOF

				cat <<- EOF > /etc/fail2ban/filter.d/traefik-botsearch.conf
				[INCLUDES]
				before = botsearch-common.conf

				[Definition]
				failregex = ^<HOST> \- \S+ \[\] \"(GET|POST|HEAD) \/<block> \S+\" 404 .+$				
				EOF

				# Action Traefik
				cat <<- EOF > /etc/fail2ban/action.d/docker-action.conf
				[Definition]
 
				actionstart = iptables -N f2b-traefik-auth
              				iptables -A f2b-traefik-auth -j RETURN
              				iptables -I FORWARD -p tcp -m multiport --dports 443 -j f2b-traefik-auth
 
				actionstop = iptables -D FORWARD -p tcp -m multiport --dports 443 -j f2b-traefik-auth
             				iptables -F f2b-traefik-auth
             				iptables -X f2b-traefik-auth
 
				actioncheck = iptables -n -L FORWARD | grep -q 'f2b-traefik-auth[ \t]'
 
				actionban = iptables -I f2b-traefik-auth -s <ip> -j DROP
 
				actionunban = iptables -D f2b-traefik-auth -s <ip> -j DROP				
				EOF

				# redémarrage des services
				cd /mnt
				docker-compose rm -fs traefik && docker-compose up -d traefik
				systemctl restart fail2ban
				fail2ban-client reload
				progress-bar 20
				echo ""
				echo -e "${CCYAN}Fail2ban a été configuré avec succés${CEND}"
				echo ""

				# Configuration Portsentry
				echo "$IP_DOM" >> /etc/portsentry/portsentry.ignore.static
				echo "$IP_SERV" >> /etc/portsentry/portsentry.ignore.static
				echo "66.249.64.0/19" >> /etc/portsentry/portsentry.ignore.static
				sed -i -e 's/BLOCK_UDP="0"/BLOCK_UDP="1"/g' /etc/portsentry/portsentry.conf
				sed -i -e 's/BLOCK_TCP="0"/BLOCK_TCP="1"/g' /etc/portsentry/portsentry.conf
				sed -i -e 's/#KILL_RUN_CMD_FIRST = "0"/KILL_RUN_CMD_FIRST = "1"/g' /etc/portsentry/portsentry.conf
				sed -i -e 's/SCAN_TRIGGER="0"/SCAN_TRIGGER="1"/g' /etc/portsentry/portsentry.conf
				sed -i -e 's/TCP_MODE="tcp"/TCP_MODE="atcp"/g' /etc/default/portsentry
				sed -i -e 's/UDP_MODE="udp"/UDP_MODE="audp"/g' /etc/default/portsentry
				echo KILL_ROUTE="/sbin/iptables -I INPUT -s \$TARGET$ -j DROP && /sbin/iptables -I INPUT -s \$TARGET$ -m limit --limit 3/minute --limit-burst 5 -j LOG --log-level DEBUG --log-prefix 'Portsentry: dropping: '" >> /etc/portsentry/portsentry.conf
				systemctl restart portsentry
				progress-bar 20
				echo ""
				echo -e "${CCYAN}Portsentry a été configuré avec succés${CEND}"
				echo ""

				# Mise en place iptables
				sed -i -e 's/22/'$PORT'/g' /etc/iptables
				read -p "Appuyer sur la touche Entrer pour continuer"
				chmod +x /etc/iptables
				/etc/iptables clear
				/etc/iptables start
				apt install iptables-persistent -y
				progress-bar 20
				echo ""
				echo -e "${CCYAN}Iptables a été configuré avec succés${CEND}"
				echo ""
				read -p "Appuyer sur la touche Entrer pour continuer"
				echo ""
				clear
				logo.sh
				;;

			esac
			done
			;;

		5) # Sauvegarde de la configuration
		clear
		logo.sh
		SAUVE=""
		sortir=false
		while [ !sortir ]
		do
		echo ""
		echo -e "${CRED}------------------------------${CEND}"
		echo -e "${CCYAN}  SAUVEGARDE - RESTAURATION  ${CEND}"
		echo -e "${CRED}------------------------------${CEND}"
		echo ""
		echo -e "${CGREEN}   1) Sauvegarde des volumes docker et de toute la configuration seedbox ${CEND}"
		echo -e "${CGREEN}   2) Restauration complète de la seedbox ${CEND}"
		echo -e "${CGREEN}   3) Retour Menu Principal${CEND}"
		echo -e ""
			read -p "Sauve choix [1-3]: " -e -i 1 SAUVE
			echo ""			
			case $SAUVE in
			
				1) # Sauvegarde des volumes
				clear
				logo.sh
				echo ""
				export $(xargs </mnt/.env)
				read -rp  "Préciser l'emplacement où vous souhaitez conserver la sauvegarde (exemple: /mnt/sauve): " EXCLUDE
				mkdir -p $EXCLUDE
				echo ""
				read -rp  "Nom que vous souhaitez attribuer à votre sauvegarde (exemple: backup): " SAUVE
				cd /
				ARCHIVE=$EXCLUDE/$SAUVE
				cat <<- EOF >> /mnt/.env
				ARCHIVE=$ARCHIVE
				EOF
				tar -zcf $EXCLUDE/$SAUVE.gz --exclude=Medias ${VOLUMES_ROOT_PATH} /mnt/docker-compose.yml /mnt/.env 2>/dev/null
				echo ""
				progress-bar 20
				echo ""
				echo -e "${CCYAN}La sauvegarde complète de la seedbox s'est bien déroulée ${CEND}"
				echo -e "${CCYAN}Il est important de sauvegarder précieusement l'archive :${CPURPLE} $ARCHIVE.gz ${CEND}"
				echo ""
				read -p "Appuyer sur la touche Entrer pour continuer"
				clear
				logo.sh

				;;

				2) # Restauration
				clear
				logo.sh
				echo ""
				read -rp "Préciser l'emplacement de l'archive (exemple: /mnt/sauve/backup.gz : " ARCHIVE
				cd /

				if [ -f "$ARCHIVE" ];then
					echo -e "${CCYAN}Archive trouvée, restauration en cours des volumes ${CEND}"
					tar xzf $ARCHIVE 2>/dev/null
					echo ""
					progress-bar 20
					echo ""
						echo -e "${CCYAN}La restauration des volumes s'est bien déroulée ${CEND}"
						echo ""
						echo -e "${CCYAN}Restauration en cours des containers ${CEND}"
						echo ""
						cd /mnt
						docker-compose up -d
						echo ""
						echo -e "${CCYAN}Restauration complète de la seedbox terminée avec succés ${CEND}"

				else
					echo ""
					echo -e "${CCYAN}Archive non trouvée, recherche sur le serveur ... ${CEND}"
					RESULTAT=$(find / -name $ARCHIVE 2>/dev/null)
					if [ -f "$RESULTAT" ];then
						echo ""
						echo -e "${CCYAN}Archive trouvée à cet emplacement ${CPURPLE}$RESULTAT${CCYAN}, restauration en cours des volumes ${CEND}"
						tar xzf $RESULTAT
						progress-bar 20
						echo ""
						echo -e "${CCYAN}La restauration des volumes s'est bien déroulée ${CEND}"
						echo ""
						echo -e "${CCYAN}Restauration en cours des containers ${CEND}"
						echo ""
						cd /mnt
						docker-compose up -d
						echo ""
						echo -e "${CCYAN}Restauration complète de la seedbox terminée avec succés ${CEND}"

					else
						echo ""
						progress-bar 20
						echo ""
						echo -e "${CRED}Aucune archive de sauvegarde n'est présente sur le serveur${CEND}"

					fi

				echo ""
				read -p "Appuyer sur la touche Entrer pour continuer"
				clear
				logo.sh
				
				fi

				;;

				3) # quitter
				sortir=true
				seedbox.sh
				;;

			esac
			done
			;;

		6)
		exit 0

		;;

	esac
