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



echo
echogreen "-----------------------------------------------------"
echoblue   "Bienvenue sur l'installeur d'Alfresco par Adil BOUZIT"
echogreen  "-----------------------------------------------------"
echo
echoblue   "L'installation via ce script requiert des privilèges administrateurs"
echoblue   "Tous les paquets seront installés dans /opt/. , des liens symboliques seront créés dans /usr/local/bin"
echo
echored    "-----------------------------------------------------"
echo
echoblue   "Voulez-vous continuer et lancer l'installation ? Y/N : " 
read accordInstallation
echo

if [ "$accordInstallation" = "y" ] 
    then
        
                
        
        
                
        #----------------------------------------------------------------#
        #     Déclaration des variables d'environnement nécessaires      #
        #----------------------------------------------------------------#
        
        sudo rm /etc/profile.d/alfresco_env.sh
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
        
        source /etc/profile.d/alfresco_env.sh
        
                
        
        
                 
        #----------------------------------------------------------------#
        #      Déclaration des variables nécessaires  pour le script     #
        #----------------------------------------------------------------#
    
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
        
                
        
        
                
        #-----------------------------------------------------------------#
        #      Installation et téléchargement des paquets nécessaires     #
        #-----------------------------------------------------------------#
        
        echoblue "les paquets suivants vont être installés : git, curl, mariadb-server, openjdk-17-jdk-headless nginx ainsi que les répertoires d'Alfresco, ActiveMQ, Apache Tomcat etc.."
        echoblue "Voulez-vous les installer ? Y/N : " 
        read reponse
        
        if [ "$reponse" = "y" ]
            then
              sudo apt-get install software-properties-common -y
              sudo add-apt-repository 'deb [arch=amd64,arm64,ppc64el] http://sfo1.mirrors.digitalocean.com/mariadb/repo/10.3/ubuntu bionic main' -y
              sudo apt update -y
              apt --purge autoremove git curl mariadb-server openjdk-17-jdk-headless nginx zip sed -y --allow-remove-essential  
              apt update -y && sudo apt upgrade -y
              apt install git curl mariadb-server openjdk-17-jdk-headless nginx zip sed -y
        else
          echo "Annulation de l'installation"
            rm /etc/profile.d/alfresco_env.sh
        fi
        
        
        #  Variables des liens de téléchargements et noms des répertoires zip
        
        AlfContentName=$ALF_HOME/alfresco-content-services-community-distribution-23.2.1
        AlfContentZip=$ALF_HOME/alfresco-content-services-community-distribution-23.2.1.zip
        AlfContentServiceUrl=https://nexus.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/alfresco-content-services-community-distribution/23.2.1/alfresco-content-services-community-distribution-23.2.1.zip
    
        AlfSearchName=$ALF_HOME/alfresco-search-services-2.0.9.1
        AlfSearchZip=$ALF_HOME/alfresco-search-services-2.0.9.1.zip   
        AlfSearchServiceUrl=https://nexus.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/alfresco-search-services/2.0.9.1/alfresco-search-services-2.0.9.1.zip
        
        ActiveMQName=$ALF_HOME/apache-activemq-6.1.2
        ActiveMQZip=$ALF_HOME/apache-activemq-6.1.2-bin.tar.gz
        ActiveMQUrl=https://dlcdn.apache.org//activemq/6.1.2/apache-activemq-6.1.2-bin.tar.gz
        
        ApacheTomcatName=$ALF_HOME/apache-tomcat-10.1.24
        ApacheTomcatZip=$ALF_HOME/apache-tomcat-10.1.24.zip
        ApacheTomcatUrl=https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.24/bin/apache-tomcat-10.1.24.zip
        SsltoolName=$ALF_HOME/alfresco-ssl-generator
        SsltoolUrl=https://github.com/Alfresco/alfresco-ssl-generator.git
        
        JDBCurl=https://dlm.mariadb.com/3752064/Connectors/java/connector-java-2.7.12/mariadb-java-client-2.7.12.jar
        JDBCname=$ALF_HOME/mariadb-java-client-2.7.12.jar
        
                
        
        
                
        #-----------------------------------#
        #      structuration d'alfresco     #
        #-----------------------------------#
        
        rm -rf $ALF_HOME
        mkdir $ALF_HOME
        cd $ALF_HOME
        
        
        # Téléchargement
        wget $AlfContentServiceUrl
        wget $AlfSearchServiceUrl
        wget $ActiveMQUrl
        wget $ApacheTomcatUrl
        wget $JDBCurl
        git clone $SsltoolUrl
        
        
        # Décompréssion
        unzip $AlfContentZip
        unzip $AlfSearchZip
        tar zxf $ActiveMQZip
        unzip $ApacheTomcatZip
        

        
        # Restructuration des répertoires
        mv $ActiveMQName $ALF_HOME/activemq
        mv $ApacheTomcatName $ALF_HOME/tomcat
        mv $SsltoolName/ssl-tool $ALF_HOME/ssl-tool
        
        # regroupement de lib dans shared [alfresco] et shared vers [tomcat]
        mv $ALF_HOME/web-server/lib $ALF_HOME/web-server/shared/.
        mv $ALF_HOME/web-server/conf/* $ALF_HOME/tomcat/conf/.
        mv $ALF_HOME/web-server/shared $ALF_HOME/tomcat/.
        mv $JDBCname $CATALINA_HOME/shared/lib/.
        
        # renommage du webapps par défaut [tomcat]
        mv $CATALINA_HOME/webapps $CATALINA_HOME/default_webapps
        
        #déplacement des webapps [alfresco} vers [tomcat]
        mv $ALF_HOME/web-server/webapps $CATALINA_HOME/.
        
        # création répertoire data [tomcat]
        mkdir $CATALINA_HOME/data
        mv $ALF_HOME/keystore $CATALINA_HOME/data/keystore
        mkdir $CATALINA_BASE/logs/alf_logs
        mkdir $CATALINA_HOME/modules
        mkdir $CATALINA_HOME/modules/platform
        mkdir $CATALINA_HOME/modules/share
        
        # Création des commandes tomcat/activemq/solr
        ln -s /opt/alfresco/tomcat/bin/catalina.sh /usr/local/bin/tomcat -f
        ln -s /opt/alfresco/activemq/bin/activemq /usr/local/bin/activemq -f
        ln -s /opt/alfresco/tomcat/bin/catalina.sh /usr/bin/tomcat -f
        ln -s /opt/alfresco/activemq/bin/activemq /usr/bin/activemq -f
        
        chmod 775 $CATALINA_HOME/bin/*.sh
        chmod 775 $ACTIVEMQ_HOME/bin/*.sh
        
        
        # Nettoyage des zip
        rm *.zip *.tar.gz
        
        # nettoyages des répertoires/fichiers non nécessaires
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
        
        
        # Saisie de mot de passe du KESYTORE     
         
        echogreen "----------KEYSTORE----------" 
        while [ ${#keypass} -lt ${#charlen} ]
          do
            read -s -p "KEYSTORE - Veuillez saisir un mot de passe de 6 caractères pour votre keystore : " keypass
          
            if [ ${#keypass} -lt ${#charlen} ]
                then
                    echo
                        echored "Votre mot de passe est trop court"
            else
                keypassverif=$keypass
                keypass=""
                echo
                read -s -p "Veuillez saisir le mot de passe à nouveau : " keypass
                    if [ "$keypass" = "$keypassverif" ]
                    then echogreen "Le mot de passe correspond !"
                    
                    else echored "Le mot de passe ne correspond pas.."
                         keypass=""               
                    fi
            fi
        done
        
        # Saisie de mot de passe du TRUSTSTORE
        
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
                    then echogreen "Le mot de passe correspond !"
                    
                    else echored "Le mot de passe ne correspond pas.."
                         trustpass=""               
                    fi
            fi
        done
        
        
        # Lancement du script de génération des clés SSL 
        
        cd $ALF_HOME/ssl-tool
        bash run.sh -keystorepass $keystorepass -truststorepass $truststorepass
        
        # déplacement du répertoire des clés #####
        mv $ALF_HOME/ssl-tool/keystores/* $CATALINA_HOME/data/keystore/.
        mv $ALF_HOME/ssl-tool/certificates $CATALINA_HOME/data/keystore/.
        mv $ALF_HOME/ssl-tool/ca $CATALINA_HOME/data/keystore/.
        
        # Suppression du répertoire SSL-TOOL
        rm -rf $ALF_HOME/ssl-tool
        
     


        #--------------------------------------------------#
        #      Création base de donnée et utilisateur      #
        #--------------------------------------------------#
        
        # Manipulation base de donnée - Création base de donnée - utilisateur base de donnée

### !!!!! Créer une boucle permettant de vérifier s'il existe déjà une BDD/utilisateur et agir en conséquence
        
        #mkdir $ALF_HOME/temp
        #mariadb -e "SHOW DATABASES;" >> $ALF_HOME/temp
        #mariadb -e "SHOW DATABASES; SELECT mysql; SELECT user FROM user;" >> $ALF_HOME/temp

        echogreen "Choisissez un nom pour la base de donnée d'Alfresco : " && read Alf_db
        echogreen "Choisissez un nom pour l'utilisateur de la base de donnée d'Alfresco : " && read Alf_db_user
        echogreen "Choisissez un mot de passe pour l'utilisateur de la bade de donnée d'Alfresco : " && read Alf_db_user_password

        echogreen "Nom de la base de donnée : $Alf_db"
        echogreen "Nom de son utilisateur : $Alf_db_user"
        echogreen "Mot de passe utilisateur : $Alf_db_password"
     
        mariadb -e "CREATE DATABASE $Alf_db CHARACTER SET utf8 COLLATE utf8_general_ci;"
        mariadb -e "CREATE USER $Alf_db_user@localhost IDENTIFIED BY '$Alf_db_user_password';"
        mariadb -e "GRANT ALL ON $Alf_db.* TO $Alf_db_user@localhost IDENTIFIED BY '$Alf_db_user_password';"
        mariadb -e "FLUSH PRIVILEGES;"
        
        # Création utilisateur Alfresco
        ALF_USER="alfresco"
        ALF_GROUP="alfresco"
        ALF_USER_PASS="alfresco"

        userdel $ALF_USER
        groupdel $ALF_GROUP
        useradd $ALF_USER -s /bin/bash

        echo "$ALF_USER:$ALF_USER_PASS" | sudo chpasswd




        #------------------------------------------------------------#
        #      Modification/Ajout des fichiers de configuration      #
        #------------------------------------------------------------#


        #------MariaDB------#
        
        ##### Fichier /etc/mysql/mariadb.conf.d/50-server.cnf  -- Ajout max connections
        max_co_mariadb="max_connections         =        275"
        sed -i "40i $max_co_mariadb" /etc/mysql/mariadb.conf.d/50-server.cnf
        sudo systemctl restart mariadb



        #------Alfresco/Tomcat------#

        ##### Configuration du fichier $CATALINA_HOME/conf/catalina.properties

        
        sed -i "s/^shared.loader=$/shared.loader=\${catalina.base}\/shared\/classes,\${catalina.base}\/shared\/lib\/*.jar/" $CATALINA_HOME/conf/catalina.properties

        #modification alfresco.xml et share.xml
        sed -i "s/.\.\.\/modules/\/modules/" $CATALINA_HOME/conf/Catalina/localhost/alfresco.xml
        sed -i "s/.\.\.\/modules/\/modules/" $CATALINA_HOME/conf/Catalina/localhost/share.xml  
        

        # Configuration du fichier $CATALINA_HOME/bin/catalina.sh - ajout d'options de lancement JVM
        JAVA_TOOL_OPTIONS_STRING="export JAVA_TOOL_OPTIONS=\"-Dencryption.keystore.type=JCEKS -Dencryption.cipherAlgorithm=DESede/CBC/PKCS5Padding -Dencryption.keyAlgorithm=DESede -Dencryption.keystore.location=/opt/alfresco/tomcat/data/keystore/keystore -Dmetadata-keystore.password=mp6yc0UD9e -Dmetadata-keystore.aliases=metadata -Dmetadata-keystore.metadata.password=oKIWzVdEdA -Dmetadata-keystore.metadata.algorithm=DESede\""
        sed -i "299i $JAVA_TOOL_OPTIONS_STRING" $CATALINA_HOME/bin/catalina.sh

        # Création du fichier alfresco.global.properties
        echo >> $CATALINA_HOME/shared/classes/alfresco-global.properties "
        dir.root=$CATALINA_HOME/data
        dir.keystore=$CATALINA_HOME/data/keystore

        db.name=$Alf_db
        db.username=$Alf_db_user
        db.password=$Alf_db_user_password
        db.port=3306
        db.host=127.0.0.1
        db.pool.max=275
        db.driver=org.mariadb.jdbc.Driver
        db.url=jdbc:mariadb://127.0.0.1 :3306/$Alf_db?useUnicode=yes&characterEncoding=UTF-8

        alfresco.context=alfresco
        alfresco.host=localhost
        alfresco.port=8080
        alfresco.protocol=http

        share.context=share
        share.host=localhost
        share.port=8080
        share.protocol=http

        user.name.caseSensitive=true
        domain.name.caseSensitive=false
        domain.separator=

        imap.server.enabled=false
        alfresco.rmi.services.host=0.0.0.0

        smart.folders.enabled=true
        smart.folders.model=alfresco/model/smartfolder.xml
        smart.folders.model.labels=alfresco/messages/smartfolder-model"


        ##### Changement propriétaire d'$ALF_HOME
        chown $ALF_USER:$ALF_USER $ALF_HOME -R 
        usermod $ALF_USER -m -d /opt/alfresco
else 
    echo "opération annulée"
    exit
fi  