#!/bin/bash
echo "========== Start intall Weblogic :"$WEBLOGICJAR"=========="

echo '# Copyright (c) 2014-2018 Oracle and/or its affiliates. All rights reserved.
[ENGINE]
#DO NOT CHANGE THIS.
Response File Version=1.0.0.0.0
[GENERIC]
INSTALL_TYPE=WebLogic Server
SOFTWARE ONLY TYPE=true
DECLINE_SECURITY_UPDATES=true
SECURITY_UPDATES_VIA_MYORACLESUPPORT=false
' > /weblogic/software/wls.rsp

echo 'inventory_loc=/weblogic/oraInventory
inst_group=oinstall' > /weblogic/software/oraInst.loc

su - oracle -c "$JAVA_HOME/bin/java -Xmx1024m -jar /weblogic/install/$WEBLOGICJAR -silent -responseFile /weblogic/software/wls.rsp -invPtrLoc /weblogic/software/oraInst.loc -jreLoc $JAVA_HOME -ignoreSysPrereqs -force -novalidation ORACLE_HOME=$ORACLE_HOME INSTALL_TYPE="WebLogic Server" "

echo "==========Weblogic install Complete=========="
