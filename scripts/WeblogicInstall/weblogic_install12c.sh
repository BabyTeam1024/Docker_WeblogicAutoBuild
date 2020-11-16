#!/bin/bash
echo "========== Start intall Weblogic :"$WEBLOGICJAR"=========="


echo '[ENGINE]
Response File Version=1.0.0.0.0
[GENERIC]
ORACLE_HOME=/weblogic/oracle/middleware
INSTALL_TYPE=Complete with Examples
MYORACLESUPPORT_USERNAME=example@example.com
MYORACLESUPPORT_PASSWORD=examplepassword01
DECLINE_SECURITY_UPDATES=true
SECURITY_UPDATES_VIA_MYORACLESUPPORT=false
PROXY_HOST=
PROXY_PORT=
PROXY_USER=
PROXY_PWD=
COLLECTOR_SUPPORTHUB_URL=' > /weblogic/software/wls.rsp

echo 'inventory_loc=/weblogic/oraInventory
inst_group=oinstall' > /weblogic/software/oraInst.loc

su - oracle -c "$JAVA_HOME/bin/java -Xmx1024m -jar /weblogic/install/$WEBLOGICJAR -silent -responseFile /weblogic/software/wls.rsp -invPtrLoc /weblogic/software/oraInst.loc"

. $WLS_HOME/server/bin/setWLSEnv.sh
echo "==========Weblogic install Complete=========="
java weblogic.version

