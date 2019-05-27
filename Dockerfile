# CentOS v6.6 with Oracle JDK v8

FROM centos:6.6
MAINTAINER Justin Grant <jlgrock@gmail.com>

ENV LANG C.UTF-8

ENV JAVA_VERSION 1.8.0.212.b04-0.el6_10

RUN yum -y update  && \
	yum clean all && \
	yum install -y java-1.8.0-openjdk-${JAVA_VERSION} \
		java-1.8.0-openjdk-devel-${JAVA_VERSION} \
		tar \
		gzip

ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk/

# Define default command.
CMD ["bash"]