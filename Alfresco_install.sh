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
cd /tmp
if [ -d "alfrescoinstall" ]; then
	#rm -rf alfrescoinstall
  mkdir alfrescoinstall
cd ./alfrescoinstall
  ls
fi


echobgreen "-----------------------------------------------------"
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
        ##################################################################
        ##### Déclaration des variables d'environnement nécessaires  #####
        ##################################################################
    
        sudo echo >> /etc/profile.d/alfresco_env.sh "#!/bin/bash
        
            
        #####  Java variables  #####
        export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
        export PATH=$JAVA_HOME/bin:$PATH
        
        #####  Alfresco variables  #####
        export ALF_HOME=/opt/alfresco
        export ALF_DATA_HOME=/opt/alfresco/tomcat/data
        export ALF_USER=alfresco
        export ALF_GROUP=alfresco
        
        #####  Alfresco search services variables  #####
        export ALF_SEARCH_HOME=$ALF_HOME/alfresco-search-services
        
        #####  ActiveMQ variables  #####
        export ACTIVEMQ_HOME=$ALF_HOME/activemq
        
        #####  Tomcat variables  #####
        export CATALINA_HOME=$ALF_HOME/tomcat
        export CATALINA_BASE=$CATALINA_HOME
        
        #####  Solr variables  #####
        export SOLR_HOME=$ALF_SEARCH/solrhome"
    
    
    
        ###################################################################
        #####  Installation et téléchargement des paquets nécessaires #####
        ###################################################################
        
        echoblue "les paquets suivants vont être installés : git, curl, mariadb-server, openjdk-17-jdk-headless nginx ainsi que les répertoires d'Alfresco, ActiveMQ, Apache Tomcat etc.."
        echoblue "Voulez-vous les installer ? Y/N : " 
        read response
        
        if [ "$reponse" = "y" ]
            then
              sudo apt update -y && sudo apt upgrade -y
              sudo apt install git curl mariadb-server openjdk-17-jdk-headless nginx -y
        else
          echo "Annulation de l'installation"
          sudo rm /etc/profile.d/alfresco_env.sh
        fi
        
        
        #####  Variables des liens de téléchargements
        
        AlfContentServiceUrl=https://nexus.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/alfresco-content-services-community-distribution/23.2.1/alfresco-content-services-community-distribution-23.2.1.zip
        
        AlfSearchServiceUrl=https://nexus.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/alfresco-search-services/2.0.9.1/alfresco-search-services-2.0.9.1.zip
        
        ActiveMqUrl=https://dlcdn.apache.org//activemq/6.1.2/apache-activemq-6.1.2-bin.tar.gz
        
        ApacheTomcatUrl=https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.24/bin/apache-tomcat-10.1.24.zip
        
    else
        exit
    fi    
        
        
        
        
    
    

