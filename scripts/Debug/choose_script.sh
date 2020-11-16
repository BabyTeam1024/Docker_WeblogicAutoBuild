#!/bin/bash

if [ `echo $WEBLOGICJAR|grep "1036"` ] ; then
  echo ****Load ver10 scripts****
  cp $WEBLOGICINSTALL/weblogic_install11g.sh $WEBLOGICINSTALL/weblogic_install.sh
  cp $CREATEDOMAIN/create_domain11g.sh $CREATEDOMAIN/create_domain.sh;
elif [ `echo $WEBLOGICJAR|grep "fmw_14"` ];then
  echo ****load ver14 scripts****
  cp $WEBLOGICINSTALL/weblogic_install14.sh $WEBLOGICINSTALL/weblogic_install.sh
  cp $CREATEDOMAIN/create_domain14.sh $CREATEDOMAIN/create_domain.sh  ;
else
  echo ****load ver12 scripts****
  cp $WEBLOGICINSTALL/weblogic_install12c.sh $WEBLOGICINSTALL/weblogic_install.sh
  cp $CREATEDOMAIN/create_domain12c.sh $CREATEDOMAIN/create_domain.sh  ;
fi
