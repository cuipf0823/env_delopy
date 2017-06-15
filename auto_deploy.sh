#!/bin/bash
#1. support Debian and ubuntu platforms
#2. using root execute shell
#3. install mysql version 5.6
#4. Using the MySQL APT Repository

#config
MYSQL_DOWNLOAD_URL=https://repo.mysql.com//mysql-apt-config_0.8.6-1_all.deb

# down mysql apt Repository
pkg_name=$(echo $MYSQL_DOWNLOAD_URL | awk -F '//' '{print $3}')
if [[ ! -e $pkg_name ]]; then
  wget $MYSQL_DOWNLOAD_URL
fi

if [[ x$(whereis mysql) = "xmysql:" ]]; then
  echo "current system not exit mysql. install mysql ..."
  # During the installation of the package, you will be asked to choose the versions of the MySQL server and other components
  dpkg -i $pkg_name
  apt-get update
  apt-get install -y mysql-server
else
  # aready installed mysql. get mysql version
  version=$( mysql --help | grep Distrib)
  echo -e "Current Mysql version: \n $version"
  echo "Is update Mysql? [yes or no]"
  read ret
  if [[ x$ret = x"yes" ||  x$ret = x"y" ]]; then
    # update mysql
    echo "update mysql ..."
    dpkg -i $pkg_name
    apt-get update
    apt-get install -y mysql-server
  fi
fi

# install apache2

exit 0
