#!/bin/bash
echo "==========Begin Create Domain=========="
echo '#!/usr/bin/python
import os, sys
readTemplate("/weblogic/oracle/middleware/wlserver/common/templates/wls/wls.jar")
cd("/Security/base_domain/User/weblogic")
cmo.setPassword("qaxateam01")
cd("/Server/AdminServer")
cmo.setName("AdminServer")
cmo.setListenPort(7001)
cmo.setListenAddress("0.0.0.0")
writeDomain("/weblogic/oracle/Domains/ExampleSilentWTDomain")
closeTemplate()
exit()' > create_domain_7001.py
. $WLS_HOME/server/bin/setWLSEnv.sh
java weblogic.WLST create_domain_7001.py
echo "==========Domain Complete=========="


