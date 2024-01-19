#!/bin/bash

# Обновление пакетов
sudo apt update
sudo apt upgrade -y
sudo apt dist-upgrade -y

# Установка необходимых пакетов
sudo apt install -y apache2 mysql-server mysql-client mysql-common php php-mysql php-xml php-mbstring php-bcmath php-ldap php-net-ldap2 php-gd php-xmlwriter php-xmlreader php-common php-curl

# Загрузка и установка Zabbix
wget https://repo.zabbix.com/zabbix/6.5/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.5-1+ubuntu$(lsb_release -rs)_all.deb
sudo dpkg -i zabbix-release_6.5-1+ubuntu$(lsb_release -rs)_all.deb
sudo apt update -y
sudo apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent

# Создание базы данных и пользователя MySQL для Zabbix
mysql -uroot -p -e "CREATE DATABASE zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;"
mysql -uroot -p -e "CREATE USER 'zabbix'@'localhost' IDENTIFIED BY 'Qwerty12';"
mysql -uroot -p -e "GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';"
mysql -uroot -p -e "SET GLOBAL log_bin_trust_function_creators = 1;"

# Импорт схемы базы данных Zabbix
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p zabbix

# Отключаем переменную после импорта схемы базы данных
mysql -uroot -p -e "SET GLOBAL log_bin_trust_function_creators = 0;"

# Настройка файла конфигурации Zabbix сервера
sudo cp /etc/zabbix/zabbix_server.conf /etc/zabbix/zabbix_server.conf.orig
sudo sed -i 's/# DBHost=localhost/DBHost=localhost/' /etc/zabbix/zabbix_server.conf
sudo sed -i 's/# DBPassword=/DBPassword=Qwerty12/' /etc/zabbix/zabbix_server.conf

# Запуск служб Zabbix
sudo systemctl restart zabbix-server
sudo systemctl restart zabbix-agent
sudo systemctl restart apache2

# Включаем запуск сервера Zabbix, агента и службы Apache2 при загрузке системы:
sudo systemctl enable zabbix-server
sudo systemctl enable zabbix-agent
sudo systemctl enable apache2

# Вывод информации о завершении установки
echo "Zabbix успешно установлен. Откройте веб-интерфейс Zabbix в вашем браузере: http://your_server_ip/zabbix"
