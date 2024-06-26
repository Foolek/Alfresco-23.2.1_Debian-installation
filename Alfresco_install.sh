#!/bin/bash#
#-----------
#Full installation of Alfresco version 23.2.1
#
#  Contain the following application:
#    * Java OpenJDK 17
#    * Apache Tomcat 10.1.24
#    * Apache ActiveMQ 6.1.2
#    * MariaDB 11.3.2
#    * MariaDB JDBC connector 2.7.12
#    * Alfresco Content Service 23.2.1
#    * Alfresco Search Services 2.0.X
#
#  Copyleft 2024 - Adminsysop - Adil BOUZIT



# Color variables
txtund=$(tput sgr 0 1)          # Underline
txtbld=$(tput bold)             # Bold
bldred=${txtbld}$(tput setaf 1) # red
bldgre=${txtbld}$(tput setaf 2) # red
bldblu=${txtbld}$(tput setaf 4) # blue
bldwht=${txtbld}$(tput setaf 7) # white
txtrst=$(tput sgr0)             # Reset
info=${bldwht}*${txtrst}        # Feedback
pass=${bldblu}*${txtrst}
warn=${bldred}*${txtrst}
ques=${bldblu}?${txtrst}

echoblue () {
    echo "${bldblu}$1${txtrst}"
}
echored () {
    echo "${bldred}$1${txtrst}"
}
echogreen () {
    echo "${bldgre}$1${txtrst}"
}



echogreen "------------------------------------------------------"
echogreen "  Bienvenue sur l'installeur d'Alfresco par S-Zilean"
echogreen "------------------------------------------------------"
echo
echogreen  "Ce script utilise le paquet "sudo" veuillez installer le paquet pour éviter les erreurs."
echogreen  "L'installation via ce script requiert des privilèges administrateurs "
echogreen  "Tous les paquets seront installés dans /opt/. , des liens symboliques seront créés dans /usr/local/bin"
echo
echogreen  "-----------------------------------------------------"
echo
echogreen   "Wish you proceed to the installation ? Please answer by "y" (yes) or "n"(no) : "
read accordInstallation
echo



#------------------------------------------#
#     Création des fonctions utilisées     #
#------------------------------------------#


# Fonction pour trouver le numéro de ligne contenant un texte recherché
find_line_number() {
    local file="$1"
    local search_text="$2"
    
    # Utiliser grep et cut pour obtenir les numéros de ligne
    grep -n "$search_text" "$file" | cut -d: -f1
}

find_line_firstword() {
    local word="$1"
    local folder="$2"
    
    # Utiliser grep et cut pour obtenir les numéros de ligne
    awk "/$word/ {print}" $folder | cut -d: -f1
}

# Function to verify if a file or directory exist and deleting it if true
deletexisting(){
    local search=$1
    if [ -n "$search" ]
    then
        echored "$search already exist and will be removed"
        rm -rf "$search"
    fi
}

find_file() {
    local file="$1"
    local folder="$2"
    find "$folder" -name "$file"
}

# Fonction génerer un mot de passe aléatoire
generate_password(){
    # Définir la longueur minimale et maximale du mot de passe
    PASSWORD=$1
    MIN_LENGTH=20
    MAX_LENGTH=20
    
    # Définir les caractères autorisés dans le mot de passe
    CHARACTERS="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    
    # Générer une longueur aléatoire pour le mot de passe
    LENGTH=$(( $RANDOM % $MAX_LENGTH + $MIN_LENGTH ))
    
    # Générer le mot de passe en utilisant une boucle
    PASSWORD=""
    for (( i = 0; i < $LENGTH; i++ )); do
        PASSWORD+="${CHARACTERS:$(( $RANDOM % ${#CHARACTERS} )):1}"
    done
    
    # Afficher le mot de passe généré
    echo $PASSWORD
}



if [ "$accordInstallation" = "y" ]
then
    #-------------------------------------------------------------#
    #    Déclaration des variables d'environnement nécessaires    #
    #-------------------------------------------------------------#
    
    # Check if the old environnement script exist and delete + replace it
    oldenv=$(find_line_firstword alfresco /etc/passwd)
    deletexisting "$oldend"
    
    sudo echo >> /etc/profile.d/alfresco_env.sh "#!/bin/bash

            # Java variables
            export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
            export PATH=$JAVA_HOME/bin:$PATH

            # Alfresco variables
            export ALF_HOME=/opt/alfresco
            export ALF_DATA_HOME=$ALF_HOME/tomcat/data


            # Alfresco search services variables
            export ALF_SEARCH_HOME=$ALF_HOME/alfresco-search-services

            # ActiveMQ variables
            export ACTIVEMQ_HOME=$ALF_HOME/activemq

            # Tomcat variables
            export CATALINA_HOME=$ALF_HOME/tomcat
            export CATALINA_BASE=$CATALINA_HOME

            # Solr variables
    export SOLR_HOME=$ALF_SEARCH/solrhome"
    
    # Actualisation des variables d'environnement
    source /etc/profile.d/alfresco_env.sh
    
    
    
    #-------------------------------------------------------------#
    #    Déclaration des variables nécessaires  pour le script    #
    #-------------------------------------------------------------#
    
    sudo rm /etc/profile.d/alfresco_env.sh
    
    #####  Java variables  #####
    JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
    
    #####  Alfresco variables  #####
    ALF_HOME=/opt/alfresco
    ALF_DATA_HOME=/opt/alfresco/tomcat/data
    ALF_USER=alfresco
    ALF_GROUP=alfresco
    ALF_USER_PASS=alfresco
    
    #####  Alfresco search services variables  #####
    ALF_SEARCH_HOME=$ALF_HOME/alfresco-search-services
    
    #####  ActiveMQ variables  #####
    ACTIVEMQ_HOME=$ALF_HOME/activemq
    
    #####  Tomcat variables  #####
    CATALINA_HOME=$ALF_HOME/tomcat
    CATALINA_BASE=$CATALINA_HOME
    
    #####  Solr variables  #####
    SOLR_HOME=$ALF_SEARCH/solrhome
    
    
    
    #------------------------------------------#
    #    Création de l'utilisateur Alfresco    #
    #------------------------------------------#
    
    
    ALF_USER="alfresco"
    ALF_GROUP="alfresco"
    ALF_USER_PASS="alfresco"
    
    ALF_USER_search=$(find_line_firstword "alfresco" "/etc/passwd")
    
    if [ -n "$ALF_USER_search" ]
    then
        # If existing, alfresco user will be removed
        userdel $ALF_USER
    fi
    
    
    # Alfresco user creation
    useradd $ALF_USER -s /bin/bash -u 1739
    echo "$ALF_USER:$ALF_USER_PASS" | sudo chpasswd
    
    
    #--------------------------------------------------------------#
    #    Installation et téléchargement des paquets nécessaires    #
    #--------------------------------------------------------------#
    
    
    # Disclaimer
    
    echored ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> PLEASE READ CAREFULLY! <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
    echored "This script contains some lines of code that purge entire packages. To avoid any problems, please run this script in a blank environment."
    echogreen "The following packages will be installed :
            *git
            *curl
            *mariadb-server
            *openjdk-17-jdk-headless
            *nginx
            alfresco and its dependencies will be installed in /opt/alfresco
    A brief summary file will be created at the end of the script."
    
    
    # Asking for installation
    
    echogreen "Wish you continue and proceed to installation ? please answer by "y" (yes) or "n" (no) : "
    while true; do
        read answer
        if [ "$answer" == "y" ] || [ "$answer" == "Y" ]; then
            # Installation
            sudo apt update -y -qq
            sudo apt autoremove git curl mariadb-server openjdk-17-jdk-headless nginx zip zip sed sed -y --allow-remove-essential
            sudo apt-get install -qq -software-properties-common -y
            sudo add-apt-repository -qq 'deb [arch=amd64,arm64,ppc64el] http://sfo1.mirrors.digitalocean.com/mariadb/repo/10.3/ubuntu bionic main' -y
            sudo apt install -qq git rsync curl mariadb-server openjdk-17-jdk-headless nginx zip zip sed sed -y
            sudo apt update -y -qq
            break
            elif [ "$answer" == "n" ] || [ "$answer" == "N" ]; then
            echo "Annulation de l'installation"
            rm /etc/profile.d/alfresco_env.sh
            # Exit installation
            exit
        else
            echogreen "Veuillez répondre par 'y' (oui) ou 'n' (non) :"
        fi
    done
    #-------------------------#
    #    Database creation    #
    #-------------------------#
    
    # Manipulation base de donnée - Création base de donnée - utilisateur base de donnée
    
    ### !!!!! Créer une boucle permettant de vérifier s'il existe déjà une BDD/utilisateur et agir en conséquence
    
    #mkdir $ALF_HOME/temp
    #mariadb -e "SHOW DATABASES;" >> $ALF_HOME/temp
    #mariadb -e "SHOW DATABASES; SELECT mysql; SELECT user FROM user;" >> $ALF_HOME/temp
    
    echogreen "----------MariaDB----------"
    echogreen "Wish you create the database his user and password with the default presset ?"
    echogreen "Please answer by "y" (yes) or "n" (no) :"
    
    
    
    Alf_db="alfresco_db"
    Alf_db_user="alfresco_user"
    Alf_db_password="alfresco_password"
    
    while true; do
        read reponse
        if [ "$reponse" = "y" ]; then
            
            #Check if Database and user already exists
            mariadb -e "SHOW DATABASES; SELECT user FROM mysql.user;" >> /opt/alfresco/tmpmaria
            findexistingdb=$(find_line_firstword "$Alf_db" "/opt/alfresco/tmpmaria")
            findexistinguser=$(find_line_firstword "$Alf_db_user" "/opt/alfresco/tmpmaria")
            
            # Removing Database if it already exist
            if [ -n $findexistingdb ]; then
                mariadb -e "DROP DATABASE $Alf_db;"
            fi
            
            # Removing user if it already exist
            if [ -n $findexistinguser ]; then
                mariadb -e "DROP USER $Alf_db_user@localhost;"
            fi
            
            # Deleting the tmp
            rm /opt/alfresco/tmpmaria
            
            break
            elif [ "$reponse" = "n" ]; then
            echogreen "Choose a name for the database : "
            read Alf_db
            echogreen "Choisissez un nom pour l'utilisateur de la base de donnée d'Alfresco : "
            read Alf_db_user
            echogreen "Choisissez un mot de passe pour l'utilisateur de la bade de donnée d'Alfresco : "
            read Alf_db_user_password
            
            #Check if Database and user already exists
            mariadb -e "SHOW DATABASES; SELECT user FROM mysql.user;" >> /opt/alfresco/tmpmaria
            findexistingdb=$(find_line_firstword "$Alf_db" "/opt/alfresco/tmpmaria")
            findexistinguser=$(find_line_firstword "$Alf_db_user" "/opt/alfresco/tmpmaria")
            
            # Removing Database if it already exist
            if [ -n $findexistingdb ]; then
                mariadb -e "DROP DATABASE $Alf_db;"
            fi
            
            # Removing user if it already exist
            if [ -n $findexistinguser ]; then
                mariadb -e "DROP USER $Alf_db_user@localhost;"
            fi
            
            # Deleting the tmp
            rm /opt/alfresco/tmpmaria
            break
        else
            echored "Please answer by "y" (yes) or "n" (no) :"
        fi
    done
    
    
    echogreen "Nom de la base de donnée : $Alf_db"
    echogreen "Nom de son utilisateur : $Alf_db_user"
    echogreen "Mot de passe utilisateur : $Alf_db_password"
    
    mariadb -e "CREATE DATABASE $Alf_db CHARACTER SET utf8 COLLATE utf8_general_ci;"
    mariadb -e "CREATE USER $Alf_db_user@localhost IDENTIFIED BY '$Alf_db_password';"
    mariadb -e "GRANT ALL ON $Alf_db.* TO '$Alf_db_user'@'localhost' IDENTIFIED BY '$Alf_db_password';"
    mariadb -e "FLUSH PRIVILEGES;"
    
    max_co_mariadb="max_connections         = 275"
    sed -i "40i $max_co_mariadb" /etc/mysql/mariadb.conf.d/50-server.cnf
    sudo systemctl restart mariadb
    
    
    
    #-----------------------------------------#
    #    Reorganization of Alfresco report    #
    #-----------------------------------------#
    
    # Deleting old alfresco folder if it exist
    findoptalf=$(find_file "/opt" "alfresco")
    
    if [ -n "$findoptalf"]; then
        echored "Un répertoire alfresco a été trouvé et va être supprimé"
        rm -rf $ALF_HOME
    fi
    
    mkdir $ALF_HOME
    cd $ALF_HOME
    
    
    #  Variables des liens de téléchargements et noms des répertoires zip
    
    AlfContentName=$ALF_HOME/alfresco-content-services-community-distribution-23.2.1
    AlfContentZip=$ALF_HOME/alfresco-content-services-community-distribution-23.2.1.zip
    AlfContentServiceUrl=https://nexus.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/alfresco-content-services-community-distribution/23.2.1/alfresco-content-services-community-distribution-23.2.1.zip
    
    AlfSearchName=$ALF_HOME/alfresco-search-services-2.0.9.1
    AlfSearchZip=$ALF_HOME/alfresco-search-services-2.0.9.1.zip
    AlfSearchServiceUrl=https://nexus.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/alfresco-search-services/2.0.9.1/alfresco-search-services-2.0.9.1.zip
    
    ApacheTomcatName=$ALF_HOME/apache-tomcat-10.1.24
    ApacheTomcatZip=$ALF_HOME/apache-tomcat-10.1.24.zip
    ApacheTomcatUrl=https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.24/bin/apache-tomcat-10.1.24.zip
    
    ActiveMQName=$ALF_HOME/apache-activemq-6.1.2
    ActiveMQZip=$ALF_HOME/apache-activemq-6.1.2-bin.tar.gz
    ActiveMQUrl=https://dlcdn.apache.org//activemq/6.1.2/apache-activemq-6.1.2-bin.tar.gz
    
    SsltoolName=$ALF_HOME/alfresco-ssl-generator
    SsltoolUrl=https://github.com/Alfresco/alfresco-ssl-generator.git
    
    JDBCurl=https://dlm.mariadb.com/3752064/Connectors/java/connector-java-2.7.12/mariadb-java-client-2.7.12.jar
    JDBCname=$ALF_HOME/mariadb-java-client-2.7.12.jar
    
    
    # Downloading all binaries repository of our dependencies
    wget $AlfContentServiceUrl
    wget $AlfSearchServiceUrl
    wget $ActiveMQUrl
    wget $ApacheTomcatUrl
    wget $JDBCurl
    git clone $SsltoolUrl
    
    
    # Unzipping our repositories
    unzip $AlfContentZip
    unzip $AlfSearchZip
    unzip $ApacheTomcatZip
    tar zxf $ActiveMQZip
    
    
    # Rename our dependency repositories
    mv $ActiveMQName $ALF_HOME/activemq
    mv $ApacheTomcatName $ALF_HOME/tomcat
    mv $SsltoolName/ssl-tool $ALF_HOME/ssl-tool
    mv $CATALINA_HOME/webapps $CATALINA_HOME/default_webapps
    
    # moving lib in shared [alfresco] and shared to [tomcat]
    mv $ALF_HOME/web-server/lib $ALF_HOME/web-server/shared/.
    mv $ALF_HOME/web-server/conf/* $ALF_HOME/tomcat/conf/.
    mv $ALF_HOME/web-server/shared $ALF_HOME/tomcat/.
    mv $JDBCname $CATALINA_HOME/shared/lib/.
    
    # moving [alfresco} webapps to [tomcat].
    mv $ALF_HOME/web-server/webapps $CATALINA_HOME/.
    
    # création répertoire data [tomcat]
    mkdir $CATALINA_HOME/data $CATALINA_BASE/logs/alf_logs $CATALINA_HOME/modules $CATALINA_HOME/modules/platform $CATALINA_HOME/modules/share
    
    # moving the keystore folder
    mv $ALF_HOME/keystore $CATALINA_HOME/data/keystore
    
    # Creating tomcat/activemq/solr commands
    ln -s /opt/alfresco/tomcat/bin/catalina.sh /usr/local/bin/tomcat -f
    ln -s /opt/alfresco/activemq/bin/activemq /usr/local/bin/activemq -f
    ln -s /opt/alfresco/tomcat/bin/catalina.sh /usr/bin/tomcat -f
    ln -s /opt/alfresco/activemq/bin/activemq /usr/bin/activemq -f
    
    # Giving execution autorisation of the binaries
    chmod 775 $CATALINA_HOME/bin/*.sh
    rm $CATALINA_HOME/bin/*.bat
    chmod 775 $ACTIVEMQ_HOME/bin/*.sh
    rm $ACTIVEMQ_HOME/bin/*.bat
    
    # Cleaning ALF_HOME
    rm *.zip *.tar.gz
    
    # Cleaning useless files from repositories
    rm -rf $ALF_HOME/*.zip $ALF_HOME/*.gz
    rm $ALF_HOME/*
    rm -rf $ALF_HOME/web-server
    rm -rf $ALF_HOME/licences
    rm -rf $SsltoolName
    rm $CATALINA_HOME/*
    rm $CATALINA_HOME/keystore/*
    
    
    
    #-----------------------------------#
    #      Génération des clés SSL      #
    #-----------------------------------#
    
    #pattern minimum
    charlen="psswrd"
    
    #mdp keystore/truststopre
    keypass=""
    trustpass=""
    
    #verification mdp
    keypassverif=
    trustpassverif=
    
    
    echogreen "Voulez-vous générer un mot de passe aléatoire ? Y(es)/n(o) :"
    read reponse
    while [ "$reponse" != "y" ] && [ "$reponse" != "n" ]
    do
        echored  "Please answer by  "y" (yes) or "n" (no) : "
        read reponse
    done
    
    if [ "$reponse" == "y" ]; then
        #Generate truststore et keystore password
        keypass=$(generate_password)
        trustpass=$(generate_password)
        
        cd $ALF_HOME/ssl-tool
        bash run.sh -keystorepass $keypass -truststorepass $keypass
        
        elif [ "$reponse" == "n" ]; then
        
        # Reading keystore password
        echogreen "----------KEYSTORE----------"
        while [ ${#keypass} -lt ${#charlen} ]
        do
            read -s -p "KEYSTORE - Veuillez saisir un mot de passe de 6 caractères pour votre keystore : " keypass
            
            if [ ${#keypass} -lt ${#charlen} ]
            then
                echo
                echored  "Votre mot de passe est trop court"
            else
                keypassverif=$keypass
                keypass=""
                echo
                read -s -p "Veuillez saisir le mot de passe à nouveau : " keypass
                if [ "$keypass" = "$keypassverif" ]
                then echogreen  "Le mot de passe correspond !"
                else echored  "Le mot de passe ne correspond pas.."
                    keypass=""
                fi
            fi
        done
        
        # Reading truststore password
        echogreen "----------TRUSTSTORE----------"
        while [ ${#trustpass} -lt ${#charlen} ]
        do
            read -s -p "TRUSTSTORE - Veuillez saisir un mot de passe de 6 caractères pour votre truststore : " trustpass
            
            if [ ${#trustpass} -lt ${#charlen} ]
            then
                echo
                echored "Votre mot de passe est trop court"
            else
                trustpassverif=$trustpass
                trustpass=""
                echo
                read -s -p "Veuillez saisir le mot de passe à nouveau : " trustpass
                if [ "$trustpass" = "$trustpassverif" ]
                then echogreen  "Le mot de passe correspond !"
                else echored  "Le mot de passe ne correspond pas.."
                    trustpass=""
                fi
            fi
        done
    fi
    
    
    # Launching the ssl-tool
    cd $ALF_HOME/ssl-tool
    bash run.sh -keystorepass $keystorepass -truststorepass $truststorepass
    
    # moving the keystores sub-folder to the correct location
    mv $ALF_HOME/ssl-tool/keystores/* $CATALINA_HOME/data/keystore/.
    mv $ALF_HOME/ssl-tool/certificates $CATALINA_HOME/data/keystore/.
    mv $ALF_HOME/ssl-tool/ca $CATALINA_HOME/data/keystore/.
    
    # Deleting the ssl-tool repo
    rm -rf $ALF_HOME/ssl-tool
    
    
    
    
    
    
    
    #------------------------------------------------------------#
    #      Modification/Ajout des fichiers de configuration      #
    #------------------------------------------------------------#
    
    #------Alfresco/Tomcat------#
    
    ##### Configuration du fichier $CATALINA_HOME/conf/catalina.properties
    sed -i "s/^shared.loader=/shared.loader=\${catalina.base}\/shared\/classes,\${catalina.base}\/shared\/lib\/*.jar/" $CATALINA_HOME/conf/catalina.properties
    
    #modification alfresco.xml et share.xml
    sed -i "s/.\.\.\/modules/\/modules/" $CATALINA_HOME/conf/Catalina/localhost/alfresco.xml
    sed -i "s/.\.\.\/modules/\/modules/" $CATALINA_HOME/conf/Catalina/localhost/share.xml
    
    
    # Configuration du fichier $CATALINA_HOME/bin/catalina.sh - ajout d'options de lancement JVM
    JAVA_TOOL_OPTIONS_STRING="export JAVA_TOOL_OPTIONS=\"-Dencryption.keystore.type=JCEKS -Dencryption.cipherAlgorithm=DESede/CBC/PKCS5Padding -Dencryption.keyAlgorithm=DESede -Dencryption.keystore.location=/opt/alfresco/tomcat/data/keystore/keystore -Dmetadata-keystore.password=mp6yc0UD9e -Dmetadata-keystore.aliases=metadata -Dmetadata-keystore.metadata.password=oKIWzVdEdA -Dmetadata-keystore.metadata.algorithm=DESede\""
    sed -i "299i $JAVA_TOOL_OPTIONS_STRING" $CATALINA_HOME/bin/catalina.sh
    
    #-------------------------------------#
    #      Alfresco-global.properties     #
    #-------------------------------------#
    echo >> $CATALINA_HOME/shared/classes/alfresco-global.properties "
dir.root=$CATALINA_HOME/data
dir.keystore=$CATALINA_HOME/data/keystore

# Solr setup
index.subsystem.name=solr6
solr.secureComms=https
solr.port=8983

# MariaDB setup
db.name=$Alf_db
db.username=$Alf_db_user
db.password=$Alf_db_password
db.port=3306
db.host=127.0.0.1
db.pool.max=275
db.driver=org.mariadb.jdbc.Driver
db.url=jdbc:mariadb://127.0.0.1:3306/$Alf_db?useUnicode=yes&characterEncoding=UTF-8

user.name.caseSensitive=true
domain.name.caseSensitive=false
domain.separator=



#ActiveMQ setup
messaging.broker.url=failover:(tcp://localhost:61616)?timeout=3000

#Context generator
alfresco.context=alfresco
alfresco.host=localhost
alfresco.port=8080
alfresco.protocol=http
share.context=share
share.host=localhost
share.port=8080
share.protocol=http



imap.server.enabled=false
alfresco.rmi.services.host=0.0.0.0
smart.folders.enabled=true
smart.folders.model=alfresco/model/smartfolder.xml
smart.folders.model.labels=alfresco/messages/smartfolder-model
    "
    
    
    #---------------------#
    #      Server.xml     #
    #---------------------#
    
    addconnector=$(find_line_number "<Service name=Catalina>" "$CATALINA_HOME/conf/server.xml")
    next_line_number=$((addconnector+1))
    
    next_line_number=$((addconnector+1))
    
    
    #---------------------#
    #      Server.xml     #
    #---------------------#
    
    #Script de lancement
    echo >> startserver.sh "#!/bin/bash
        activemq start
    tomcat start"
    
    
    ##### Changement propriétaire d'$ALF_HOME
    chown $ALF_USER:$ALF_USER $ALF_HOME -R
    usermod $ALF_USER -m -d /opt/alfresco
    
    echogreen "Nom d'utilisateur : alfresco"
    echogreen "Mot de passe : alfresco"
    echo
    echoblue "Pour vous connecter lancez la commande : su alfresco"
    echogreen "INSTALLATION TERMINÉE"
    
else
    echo "opération annulée"
    exit
fi
