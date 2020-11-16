# Docker 自动化搭建全版本Weblogic服务

---



# 0x01 写在最前面


在Weblogic 介绍中大概描述了Weblogic的基本情况，近几年Weblogic服务架构以及其组件的漏洞频出，为了快速响应Weblogic相关漏洞，特地研究了Weblogic各个版本的快速构建，包含实体环境和基于Docker的虚拟环境。最终目的是能够实现一键自动化部署，适配所有weblogic版本，为了记录在这期间学习的东西，开了本小节进行归纳整理。


在本篇文章中将会有以下内容


1. Weblogic 相关概念的具体配置
1. Linux 无界面下Weblogic环境和调试搭建
1. Docker 自动化部署Weblogic服务



Docker自动化部署适配的版本


- [x] 10.3.6.0.0
- [x] 12.1.3.0.0
- [x] 12.2.1.1.0
- [x] 12.2.1.2.0
- [x] 12.2.1.3.0
- [x] 12.2.1.4.0
- [x] 14.1.1.0.0



# 0x02 相关概念具体配置


## 0x1 用低权限用户启动


```bash
groupadd -g 1000 oinstall && useradd -u 1100 -g oinstall oracle
```


## 0x2 安装参数


10.3.6 低版本安装时可以指定-silent_xml 参数进行配置


```xml
<?xml version="1.0" encoding="UTF-8"?>
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
</bea-installer>
```

---

12以上的高版本可以指定responseFile（响应文件）和 invPtrLoc（初始化环境文件）参数，这两个文件一定要写全


responseFile


```
[ENGINE]
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
COLLECTOR_SUPPORTHUB_URL=
```


invPtrLoc


```
inventory_loc=/weblogic/oraInventory
inst_group=oinstall
```


## 0x3 创建域


### 1. 低版本创建


create_domain_7001.py


```
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
exit()
```


生成创建脚本之后 用下面语句执行该脚本


```
java weblogic.WLST create_domain_7001.py
```


### 2. 高版本创建


其中create-wls-domain.py内容和低版本相似


```bash
/weblogic/oracle/wlserver/common/bin/wlst.sh -skipWLSModuleScanning -loadProperties $PROPERTIES_FILE  /weblogic/oracle/create-wls-domain.py
```


## 0x4 打开调试模式


```
sed '1 adebugFlag=\"true\"' -i /weblogic/oracle/Domains/ExampleSilentWTDomain/bin/setDomainEnv.sh
sed '2 aexport debugFlag' -i /weblogic/oracle/Domains/ExampleSilentWTDomain/bin/setDomainEnv.sh
```


# 0x03 详细设计


## 0x1 整体考虑


将指定的JAVA环境和Weblogic安装包放在目录下，执行脚本就可以自动化校验安装。


## 0x2 项目结构


```bash
├── docker-compose.yml
├── dockerfile
├── WeblogicDockerBuild.sh
├── scripts
│   ├── CreateDomain
│   │   ├── create_domain11g.sh
│   │   ├── create_domain12c.sh
│   │   └── create_domain14.sh
│   ├── Debug
│   │   ├── choose_script.sh
│   │   └── open_debug_mode.sh
│   ├── StartUp
│   │   └── startWebLogic.sh
│   └── WeblogicInstall
│       ├── weblogic_install11g.sh
│       ├── weblogic_install12c.sh
│       └── weblogic_install14.sh
├── jdk_use
│   └── jdk-8u271-linux-x64.tar.gz
└── weblogic_use
    └── fmw_12.2.1.2.0_wls.jar
```


1. dockerfile 和docker-compose.yml 两个文件负责docker镜像和容器的构建
1. WeblogicDockerBuild.sh 负责向docker-compose传递和初始化变量
1. scripts文件夹下存储了创建域、安装、启动、开启调试等脚本
1. jdk_use和weblogic 存放将要安装的软件



## 0x3 设计步骤


1. 通过WeblogicDockerBuild.sh 获取jdk_use 和weblogic_use 两个目录下的安装压缩包并进行校验，将获取的参数传递给环境变量，执行docker-compose
1. docker-compose 根据.env文件获取环境变量，传递给dockerfile，并编写好容器的相关属性
1. dockerfile 在接到传递的参数后分别执行，JDK安装、创建低权限用户、创建安装存储文件夹、创建环境变量、传入Weblogic安装包、根据版本选择script脚本集、执行与版本相对应的script安装部署脚本、执行版本相对应的启动脚本。



# 0x04 具体实现


## 0x1 docker-compose


```dockerfile
version: '3'
services:
  weblogic:
    build:
      context: .
      args:
        JDK: ${jdk}
        JDKPATH: ${jdkpath}
        WEBLOGICJAR: ${weblogicjar}
    tty: true
    ports:
      - "7001:7001"
      - "8453:8453"
      - "5556:5556"
```


## 0x2 Dockerfile


基于ubuntu18.04 原始镜像，安装起来方便快捷


```dockerfile
FROM ubuntu:18.04
MAINTAINER 4ct10n

# ARGS FROM Docker-compose.yml
ARG JDK
ARG JDKPATH
ARG WEBLOGICJAR

# Install Java

RUN mkdir -p /opt/jdk
ADD jdk_use/$JDK /opt/jdk/
ENV JAVA_HOME /opt/jdk/$JDKPATH
ENV PATH $PATH:$JAVA_HOME/bin
ENV WEBLOGICJAR $WEBLOGICJAR
# Create User
RUN groupadd -g 1000 oinstall && useradd -u 1100 -g oinstall oracle

# Create Directory and add ENV

RUN mkdir -p /weblogic/scripts && \
    mkdir -p /weblogic/install && \
    mkdir -p /weblogic/software && \
    mkdir -p /weblogic/oracle/middleware && \
    mkdir -p /weblogic/oracle/config/domains && \
    mkdir -p /weblogic/oracle/config/applications && \
    mkdir -p /weblogic/oracle/properties && \
    chown -R oracle:oinstall /weblogic && \
    chmod -R 775 /weblogic/

ENV MW_HOME=/weblogic/oracle/middleware
ENV WLS_HOME=$MW_HOME/wlserver
ENV WL_HOME=$WLS_HOME
ENV ORACLE_HOME=/weblogic/oracle
ENV CREATEDOMAIN=/weblogic/scripts/CreateDomain
ENV WEBLOGICINSTALL=/weblogic/scripts/WeblogicInstall
# Copy files
COPY weblogic_use/$WEBLOGICJAR /weblogic/install
COPY /scripts /weblogic/scripts/

# Choose version scripts and give exec privilege
RUN chmod -R +x  /weblogic/scripts/

RUN /weblogic/scripts/Debug/choose_script.sh
# Begin install
RUN /weblogic/scripts/WeblogicInstall/weblogic_install.sh
RUN /weblogic/scripts/CreateDomain/create_domain.sh
RUN /weblogic/scripts/Debug/open_debug_mode.sh

CMD ["/weblogic/scripts/StartUp/startWebLogic.sh"]
EXPOSE 7001
```


在dockerfile中考虑了几点


1. 为script脚本传递参数使用的是全局环境变量
1. CMD启动脚本是自己抽象出来的一层代码，负责解决不同版本之间启动脚本不同带了的问题



## 0x3 相关script脚本


创建域、安装weblogic、打开调试的脚本已经在上文中介绍过了这里主要介绍版本选择脚本和启动脚本


### 1. 版本选择配置脚本


主要针对三个不同的weblogic版本，选择相对应的脚本


```
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
```


### 2. 启动脚本


针对weblogic 14 启动脚本不同于低版本进行的判断


```
#!/bin/bash

if [ `echo $WEBLOGICJAR|grep "fmw_14"` ] ;then
#  /bin/bash
  /weblogic/oracle/user_projects/domains/base_domain/bin/startWebLogic.sh
else
  /weblogic/oracle/Domains/ExampleSilentWTDomain/bin/startWebLogic.sh
fi
```


# 0x05 使用步骤


git clone [https://github.com/BabyTeam1024/WeblogicAutoBuild.git](https://github.com/BabyTeam1024/WeblogicAutoBuild.git)


## 0x1 下载并放置安装包


在两个use目录下，分别放置JDK安装包和Weblogic安装包
![](https://cdn.nlark.com/yuque/0/2020/jpeg/2771021/1605525994774-358584a2-2e18-4cf4-a7b5-6602d3111bf6.jpeg#align=left&display=inline&height=116&margin=%5Bobject%20Object%5D&originHeight=116&originWidth=800&size=0&status=done&style=none&width=800)


这里需要注意的是两个use目录下最好只放一个文件如下图所示：


![](https://cdn.nlark.com/yuque/0/2020/jpeg/2771021/1605525994698-21c6eff1-cdc3-41bc-9e91-3bfb3476a1c9.jpeg#align=left&display=inline&height=212&margin=%5Bobject%20Object%5D&originHeight=212&originWidth=432&size=0&status=done&style=none&width=432)


## 0x2 运行构造脚本


之后运行在项目根目录下的配置脚本 WeblogicDockerBuild.sh


![](https://cdn.nlark.com/yuque/0/2020/jpeg/2771021/1605525994718-04d27afe-68ff-4860-b5ff-f56529c9c8de.jpeg#align=left&display=inline&height=330&margin=%5Bobject%20Object%5D&originHeight=330&originWidth=690&size=0&status=done&style=none&width=690)


## 0x3 运行docker容器


到此时相对应版本的Weblogic镜像已经生成了，只需要根据docker-compose.yml 构造相应的容器即可。


![](https://cdn.nlark.com/yuque/0/2020/jpeg/2771021/1605525994800-c7db02c7-8714-4fb5-8652-7b3f98c50f36.jpeg#align=left&display=inline&height=92&margin=%5Bobject%20Object%5D&originHeight=92&originWidth=800&size=0&status=done&style=none&width=800)


大功告成
