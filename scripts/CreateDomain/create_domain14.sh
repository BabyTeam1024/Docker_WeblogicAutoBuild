#!/bin/bash
cd $ORACLE_HOME
export DOMAIN_HOME=/weblogic/oracle/user_projects/domains/base_domain
export PROPERTIES_FILE=/weblogic/oracle/properties/domain.properties
echo "==========Begin Create Domain=========="

echo 'username=weblogic
password=Oracle14c' > $PROPERTIES_FILE

echo '#!/usr/bin/python
domain_name  = os.environ.get("DOMAIN_NAME", "base_domain")
admin_name  = os.environ.get("ADMIN_NAME", "AdminServer")
admin_listen_port   = int(os.environ.get("ADMIN_LISTEN_PORT", "7001"))
domain_path  = "/weblogic/oracle/user_projects/domains/%s" % domain_name
production_mode = os.environ.get("PRODUCTION_MODE", "prod")
administration_port_enabled = os.environ.get("ADMINISTRATION_PORT_ENABLED", "true")
administration_port = int(os.environ.get("ADMINISTRATION_PORT", "9002"))

print("domain_name                 : [%s]" % domain_name);
print("admin_listen_port           : [%s]" % admin_listen_port);
print("domain_path                 : [%s]" % domain_path);
print("production_mode             : [%s]" % production_mode);
print("admin name                  : [%s]" % admin_name);
print("administration_port_enabled : [%s]" % administration_port_enabled);
print("administration_port         : [%s]" % administration_port);

# Open default domain template
# ============================
readTemplate("/weblogic/oracle/wlserver/common/templates/wls/wls.jar")

set("Name", domain_name)
setOption("DomainName", domain_name)

# Set Administration Port
# =======================
if administration_port_enabled != "false":
   set("AdministrationPort", administration_port)
   set("AdministrationPortEnabled", "true")

# Disable Admin Console
# --------------------
# cmo.setConsoleEnabled(false)

# Configure the Administration Server and SSL port.
# =================================================
cd("/Servers/AdminServer")
set("Name", admin_name)
set("ListenAddress", "")
set("ListenPort", admin_listen_port)
if administration_port_enabled != "false":
   create("AdminServer","SSL")
   cd("SSL/AdminServer")
   set("Enabled", "True")

# Define the user password for weblogic
# =====================================
cd(("/Security/%s/User/weblogic") % domain_name)
cmo.setName(username)
cmo.setPassword(password)

# Write the domain and close the domain template
# ==============================================
setOption("OverwriteDomain", "true")
setOption("ServerStartMode",production_mode)

# Create Node Manager
# ===================
#cd("/NMProperties")
#set("ListenAddress","")
#set("ListenPort",5556)
#set("CrashRecoveryEnabled", "true")
#set("NativeVersionEnabled", "true")
#set("StartScriptEnabled", "false")
#set("SecureListener", "false")
#set("LogLevel", "FINEST")

# Set the Node Manager user name and password
# ===========================================
#cd("/SecurityConfiguration/%s" % domain_name)
#set("NodeManagerUsername", username)
#set("NodeManagerPasswordEncrypted", password)

# Write Domain
# ============
writeDomain(domain_path)
closeTemplate()

# Exit WLST
# =========
exit()
' > /weblogic/oracle/create-wls-domain.py
/weblogic/oracle/wlserver/common/bin/wlst.sh -skipWLSModuleScanning -loadProperties $PROPERTIES_FILE  /weblogic/oracle/create-wls-domain.py
mkdir -p ${DOMAIN_HOME}/servers/AdminServer/security/
USER=`awk '{print $1}' $PROPERTIES_FILE | grep username | cut -d "=" -f2`
PASS=`awk '{print $1}' $PROPERTIES_FILE | grep password | cut -d "=" -f2`

echo "username=${USER}" >> $DOMAIN_HOME/servers/AdminServer/security/boot.properties
echo "password=${PASS}" >> $DOMAIN_HOME/servers/AdminServer/security/boot.properties
echo `ls -al ${DOMAIN_HOME}`
echo "here"
${DOMAIN_HOME}/bin/setDomainEnv.sh
echo "==========Domain Complete=========="