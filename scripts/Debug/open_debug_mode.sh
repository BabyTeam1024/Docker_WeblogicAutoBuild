#!/bin/bash
echo "==========Open Debug mode=========="
sed '1 adebugFlag=\"true\"' -i /weblogic/oracle/Domains/ExampleSilentWTDomain/bin/setDomainEnv.sh
sed '2 aexport debugFlag' -i /weblogic/oracle/Domains/ExampleSilentWTDomain/bin/setDomainEnv.sh
echo "==========Already Opened=========="