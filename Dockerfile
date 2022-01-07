# 基础镜像系统版本为 CentOS:7
FROM centos:7

# 维护者信息
LABEL maintainer="Rabbir admin@cs.cheap"

# Docker 内用户切换到 root
USER root

# 设置时区为东八区
ENV TZ Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime > /etc/timezone

# 安装 Git 和 Wget
RUN yum -y install wget
RUN yum -y install git

# 切换到 /usr/local/ 目录下
WORKDIR /usr/local/
# 下载解压 JDK
RUN wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie"  http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.tar.gz
RUN tar -zxvf jdk-8u131-linux-x64.tar.gz
RUN mv jdk1.8.0_131  jdk1.8
RUN rm -f jdk-8u131-linux-x64.tar.gz

# 添加容器内的永久环境变量
RUN sed -i "2 a export JAVA_HOME=/usr/local/jdk1.8" /etc/profile
RUN sed -i "3 a export PATH=\$PATH:\$JAVA_HOME/bin" /etc/profile
RUN sed -i "4 a export CLASSPATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar" /etc/profile
RUN source /etc/profile
RUN sed -i '1 a source /etc/profile' ~/.bashrc
RUN source ~/.bashrc

# 添加构建用的临时环境变量
ENV JAVA_HOME /usr/local/jdk1.8
ENV PATH $PATH:$JAVA_HOME/bin
ENV CLASSPATH .:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar

# 克隆源码并修改 demo.sh 文件
WORKDIR /usr/local/
RUN git clone https://github.com/nobodyiam/apollo-build-scripts
WORKDIR /usr/local/apollo-build-scripts/
RUN sed -i 's#jdbc:mysql://localhost:3306/ApolloConfigDB?characterEncoding=utf8&serverTimezone=Asia/Shanghai#$APOLLO_CONFIG_DB_JDBC#' demo.sh
RUN sed -i 's#jdbc:mysql://localhost:3306/ApolloPortalDB?characterEncoding=utf8&serverTimezone=Asia/Shanghai#$APOLLO_PORTAL_DB_JDBC#' demo.sh

# 创建启动脚本
RUN echo "/bin/bash /usr/local/apollo-build-scripts/demo.sh start && tail -f /dev/null" > start.sh

# 启动命令
ENTRYPOINT ["/bin/bash", "start.sh"]
CMD [""]