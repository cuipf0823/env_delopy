#!/bin/bash
#1. support Debian or ubuntu platforms
#2. using root execute shell
#3. install mysql version 5.6
#4. Using the MySQL APT Repository

# config
# MySQL DownLoad URL
MYSQL_DOWNLOAD_URL=https://repo.mysql.com//mysql-apt-config_0.8.6-1_all.deb
# MySQL IP address
MYSQL_IP=''
# Usually will not change
MYSQL_PORT='3306'
MYSQL_USER='root'
MYSQL_PWD='123456'
PHPMYADMIN_URL='http://10.1.1.1/phpmyadmin/'


os_str=$(lsb_release -i | awk  '{print $3}')
if [[ x"${os_str:0:6}" = x"Ubuntu" || x"${os_str:0:6}" = x"Debian" ]]; then
  echo "Current OS: $os_str start deploy..."
else
  echo "Current OS: $os_str not supported exit "
  exit 0
fi

set_value()
{
	local file=$1
	local key=$2
	local value=$3
	if [ -z $file -o -z $key -o -z $value ];then
		return 1
	fi

	if [ -f $file ] && cat $file | grep "^$key" > /dev/null; then
		sed -i "/^$key/d" $file
	fi

	echo "${key} = ${value}" >> $file
	return 0
}

set_value ./config.inc.php "\$cfg['PmaAbsoluteUri']" $PHPMYADMIN_URL

exit 0

# down mysql apt Repository
pkg_name=$(echo $MYSQL_DOWNLOAD_URL | awk -F '//' '{print $3}')
if [[ ! -e $pkg_name ]]; then
  wget $MYSQL_DOWNLOAD_URL
fi

if [[ x$(whereis mysql) = x"mysql:" ]]; then
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

# mysql config
\cp ./my.cnf /etc/my.cnf

# install apache2
if [[ x$(whereis apache2) = x"apache2:" ]]; then
  apt-get install -y apache2
fi

# install php
apt-get install -y php5

# install other components
apt-get install -y libapache2-mod-php5 php5-gd php5-mysql

# install phpmyadmin
apt-get install -y phpmyadmin

# soft link
ln -s /usr/share/phpmyadmin /var/www/html
echo 'Include /etc/phpmyadmin/apache.conf' >> /etc/apache2/apache2.conf
service apache2 restart

# Modify phpmyadmin config
# first backup
\cp /etc/phpmyadmin/config.inc.php /etc/phpmyadmin/config.inc.php.bk

set_value()
{
	local file=$1
	local key=$2
	local value=$3
	if [ -z $file -o -z $key -o -z $value ];then
		return 1
	fi

	if [ -f $file ] && cat $file | grep "^$key" > /dev/null; then
		sed -i "/^$key/d" $file
	fi

	echo "${key} = ${value}" >> $file
	return 0
}

exit 0
