#!/bin/bash

# Обновление системы
sudo apt update
sudo apt upgrade -y
sudo apt dist-upgrade -y

# Установка необходимых зависимостей
sudo apt install -y apache2 php libapache2-mod-php php-gd libgd-dev unzip build-essential libc6-dev libperl-dev libssl-dev daemon wget

# Создание пользователей и групп
sudo useradd nagios
sudo groupadd nagcmd
sudo usermod -aG nagcmd nagios
sudo usermod -aG nagcmd www-data

# Загрузка Nagios и плагинов
wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.5.0.tar.gz
wget https://nagios-plugins.org/download/nagios-plugins-2.4.8.tar.gz

# Распаковка архивов
tar -zxvf nagios-4.5.0.tar.gz
tar -zxvf nagios-plugins-2.4.8.tar.gz

# Сборка и установка Nagios
cd nagios-4.5.0
sudo ./configure --with-command-group=nagcmd
make all
sudo make install
sudo make install-init
sudo make install-commandmode
sudo make install-config
sudo make install-webconf
sudo make install-exfoliation
sudo a2enmod cgi
sudo systemctl restart apache2
sudo systemctl enable nagios.service

# Настройка пользователя администратора Nagios
sudo htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin

# Сборка и установка плагинов
cd ../nagios-plugins-2.4.8
sudo ./configure --with-nagios-user=nagios --with-nagios-group=nagios
make
sudo make install

# Запуск Nagios
sudo systemctl start nagios

# Вывод информации о завершении установки
echo "Nagios успешно установлен. Откройте веб-интерфейс Nagios в вашем браузере: http://your_server_ip/nagios"
