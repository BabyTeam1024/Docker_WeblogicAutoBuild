#!/bin/bash

if [ `echo $WEBLOGICJAR|grep "fmw_14"` ] ;then
#  /bin/bash
  /weblogic/oracle/user_projects/domains/base_domain/bin/startWebLogic.sh
else
  /weblogic/oracle/Domains/ExampleSilentWTDomain/bin/startWebLogic.sh
fi