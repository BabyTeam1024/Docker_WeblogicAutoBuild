#!/bin/bash
echo "========== Start intall Weblogic :"$WEBLOGICJAR"=========="

echo '<?xml version="1.0" encoding="UTF-8"?>
   <bea-installer>
     <input-fields>
       <data-value name="BEAHOME" value="/weblogic/oracle/middleware" />
       <data-value name="WLS_INSTALL_DIR" value="/weblogic/oracle/middleware/wlserver" />
       <data-value name="COMPONENT_PATHS"
        value="WebLogic Server/Core Application Server|WebLogic Server/Administration Console|WebLogic Server/Configuration Wizard and Upgrade Framework|WebLogic Server/Web 2.0 HTTP Pub-Sub Server|WebLogic Server/WebLogic JDBC Drivers|WebLogic Server/Third Party JDBC Drivers|WebLogic Server/WebLogic Server Clients|WebLogic Server/WebLogic Web Server Plugins|WebLogic Server/UDDI and Xquery Support|Oracle Coherence/Coherence Product Files" />
       <data-value name="INSTALL_NODE_MANAGER_SERVICE" value="yes" />
       <data-value name="NODEMGR_PORT" value="5556" />
       <data-value name="INSTALL_SHORTCUT_IN_ALL_USERS_FOLDER" value="no"/>
       <data-value name="LOCAL_JVMS" value="/java"/>
   </input-fields>
</bea-installer>' > /weblogic/software/silent.xml

$JAVA_HOME/bin/java -Xmx1024m -jar /weblogic/install/$WEBLOGICJAR -mode=silent -silent_xml=/weblogic/software/silent.xml

. $WLS_HOME/server/bin/setWLSEnv.sh
echo "==========Weblogic install Complete=========="
java weblogic.version

