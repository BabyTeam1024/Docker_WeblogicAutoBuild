#!/bin/bash
jdk=`ls jdk_use|head -n 1`
weblogicjar=`ls weblogic_use|grep "jar"|head -n 1`
if [[ "$jdk" = "" || "$weblogicjar" = "" ]]; then
  echo "[-] Missing JDK or Weblogic packages"
  exit 0
fi

if [ -z `echo $weblogicjar|grep ".jar"` ]; then
  echo "[-] Weblogic package must be .jar"
  exit 0
fi
tempjdkpath=`tar -tf jdk_use/$jdk | head -n 1`
jdkpath=${tempjdkpath%/*}
echo "jdk=$jdk" > .env
echo "jdkpath=$jdkpath" >> .env
echo "weblogicjar=$weblogicjar" >> .env
docker-compose build
