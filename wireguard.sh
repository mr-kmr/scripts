#!/bin/bash

# Обновляем список пакетов и устанавливаем необходимые зависимости
sudo apt update
sudo apt install -y wireguard-tools

# Устанавливаем ядро WireGuard (если оно еще не установлено)
sudo apt install -y linux-headers-$(uname -r)

# Загружаем модуль ядра WireGuard
sudo modprobe wireguard

# Генерируем публичный и приватный ключи
wg genkey | sudo tee /etc/wireguard/privatekey | wg pubkey | sudo tee /etc/wireguard/publickey

# Для работы NAT необходимо включить переадресацию IP-адресов
cd /etc/
cat << EOF > sysctl.conf
net.ipv4.ip_forward=1
EOF

sudo sysctl -p

# Конфигурируем WireGuard
cd /etc/wireguard/
cat << EOF > wg0.conf
[Interface]
Address = 10.0.0.1/24
SaveConfig = true
ListenPort = 1715
PrivateKey = PlmkI/mK/vNOEtdoYuxHseBsu5ZaH3M9zK9YIZiCC2k=
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
EOF

sudo wg show wg0
ip a show wg0
read -n 1 -s -r -p "Wireguard установлен. Нажмите Enter для продолжения..."

# Включаем и запускаем службу WireGuard-UI
sudo systemctl enable wg-quick@wg0
sudo systemctl start wg-quick@wg0
sudo systemctl status wg-quick@wg0

# Настроим UFW, разрешив необходимые порты
sudo ufw allow 5000 # Порт для WireGuard-UI
sudo ufw allow 1715/udp # Порт по умолчанию для WireGuard

# Включаем файрволл UFW и разрешаем SSH
sudo ufw allow OpenSSH

# Включаем UFW и активируем правила
sudo ufw enable

# Устанавливаем WireGuard-UI
cd
wget https://github.com/ngoduykhanh/wireguard-ui/releases/download/v0.6.2/wireguard-ui-v0.6.2-linux-amd64.tar.gz
tar -xvf wireguard-ui-v0.6.2-linux-amd64.tar.gz

# Запускаем wireguard-ui в фоновом режиме
nohup ./wireguard-ui &

# Даем wireguard-ui немного времени для запуска
sleep 5

# Ожидаем нажатия Enter, чтобы продолжить
read -n 1 -s -r -p "Wireguard-ui запущен в фоновом ежиме. Нажмите Enter для продолжения..."

# Auto restart WireGuard-UI daemon
cd /etc/systemd/system/
cat << EOF > wgui.service
[Unit]
Description=Restart WireGuard
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/bin/systemctl restart wg-quick@wg0.service

[Install]
RequiredBy=wgui.path
EOF

cd /etc/systemd/system/
cat << EOF > wgui.path
[Unit]
Description=Watch /etc/wireguard/wg0.conf for changes

[Path]
PathModified=/etc/wireguard/wg0.conf

[Install]
WantedBy=multi-user.target
EOF

# Включаем и запускаем wgui
systemctl enable wgui.{path,service}
systemctl start wgui.{path,service}

# Устанавливем speedtest
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
sudo apt-get install speedtest

# Устанавливаем net-tools
sudo apt-get install net-tools

# Выводим информацию о настройке сервера
echo "Speedtest и net-tools установлены"
echo "WireGuard и WireGuard-UI успешно установлены и настроены"
echo "WireGuard-UI будет слушать на порту 5000"
