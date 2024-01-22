#!/bin/bash

# Обновляем список пакетов
sudo apt update
sudo apt upgrade -y
sudo apt dist-upgrade -y

# Устанавливаем необходимые пакеты
sudo apt install -y apache2 mysql-server php libapache2-mod-php php-mysql php-snmp rrdtool snmp snmpd

# Установка дополнительных зависимостей
sudo apt install -y autoconf automake build-essential libtool libc6-dev libsnmp-dev libmysql++-dev libssl-dev libmysqlclient-dev librrd-dev libboost-dev libboost-iostreams-dev libboost-filesystem-dev libboost-program-options-dev libboost-system-dev libboost-regex-dev libboost-thread-dev libboost-graph-dev libboost-test-dev libboost-chrono-dev libboost-date-time-dev libboost-atomic-dev libboost-timer-dev libboost-locale-dev libboost-coroutine-dev libboost-context-dev libboost-serialization-dev libsnmp-perl php-net-socket php-net-ldap2 php-mail-mime php-net-smtp php-mbstring php-bcmath

# Создаем базу данных и пользователя для Cacti
mysql -u root -p -e "CREATE DATABASE cacti;"
mysql -u root -p -e "CREATE USER 'cactiuser'@'localhost' IDENTIFIED BY 'Qwerty12';"
mysql -u root -p -e "GRANT ALL PRIVILEGES ON cacti.* TO 'cactiuser'@'localhost';"
mysql -u root -p -e "FLUSH PRIVILEGES;"

# Загружаем и устанавливаем Cacti
sudo apt install -y cacti

# Настраиваем базу данных для Cacti
sudo cacti-setup

# Настраиваем Apache
sudo sed -i 's/Require host localhost/Require all granted/' /etc/apache2/conf-available/cacti.conf
sudo a2enconf cacti

# Перезапускаем Apache
sudo systemctl restart apache2

echo "Cacti успешно установлен и настроен. Откройте веб-браузер и перейдите по адресу http://ваш_сервер/cacti/"
