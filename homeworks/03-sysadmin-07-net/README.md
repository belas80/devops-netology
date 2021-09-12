# 3.7. Компьютерные сети, лекция 2

1. Список доступных сетевых интерфейсов
   ```bash
   vagrant@vagrant:~$ ip -c -br link 
   lo               UNKNOWN        00:00:00:00:00:00 <LOOPBACK,UP,LOWER_UP> 
   eth0             UP             08:00:27:73:60:cf <BROADCAST,MULTICAST,UP,LOWER_UP> 
   ```
2. Для распознавания соседа по сети используется протокол LLDP. В линуск есть пакет `lldpd` и команды `lldpctl`, `lldpcli` для работы с ним.
   ```bash
   vagrant@vagrant:~$ lldpcli help
    
   -- Help
         show  Show running system information
        watch  Monitor neighbor changes
       update  Update information and send LLDPU on all ports
         help  Get help on a possible command
        pause  Pause lldpd operations
       resume  Resume lldpd operations
         exit  Exit interpreter
   
   vagrant@vagrant:~$ lldpcli show neighbors 
   -------------------------------------------------------------------------------
   LLDP neighbors:
   -------------------------------------------------------------------------------
   ```
3. Для разделения L2 коммутатора на виртуальные сети используется VLAN. Так же есть одноименный пакет `vlan`.  
   Примеры конфигов в `/etc/network/interfaces` из `man vlan-interfaces`
   ```bash
   iface eth0.1 inet static
            address 192.168.1.1
            netmask 255.255.255.0
   
   iface vlan1 inet static
            vlan-raw-device eth0
            address 192.168.1.1
            netmask 255.255.255.0
   
   iface eth0.0001 inet static
            address 192.168.1.1
            netmask 255.255.255.0
   
   iface vlan0001 inet static
            vlan-raw-device eth0
            address 192.168.1.1
            netmask 255.255.255.0
   ```
4. В Linux есть следующие типы агрегации интерфейсов, опция `mode` или `bond-mode`
   1. `balance-rr or 0` (по умолчанию) - В данном режиме сетевые пакеты отправляются “по кругу”, от первого интерфейса к последнему.
   2. `active-backup or 1` - Один из интерфейсов работает в активном режиме, остальные в ожидающем. При обнаружении проблемы на активном интерфейсе производится переключение на ожидающий интерфейс.
   3. `balance-xor or 2` - Передача пакетов распределяется по типу входящего и исходящего трафика по формуле ((MAC src) XOR (MAC dest)) % число интерфейсов. Режим дает балансировку нагрузки и отказоустойчивость.
   4. `broadcast or 3` - Происходит передача во все объединенные интерфейсы, тем самым обеспечивая отказоустойчивость.
   5. `802.3ad or 4` - динамическое объединение одинаковых портов. В данном режиме можно значительно увеличить пропускную способность входящего так и исходящего трафика. Для данного режима необходима поддержка и настройка коммутатора.
   6. `balance-tlb or 5` - Адаптивная балансировки нагрузки трафика. Входящий трафик получается только активным интерфейсом, исходящий распределяется в зависимости от текущей загрузки канала каждого интерфейса.
   7. `balance-alb or 6` - Адаптивная балансировка нагрузки. Отличается более совершенным алгоритмом балансировки нагрузки чем предыдущий режим 5. Обеспечивается балансировка нагрузки как исходящего, так и входящего трафика.  
   Пример конфига с двумя проводными интерфейсами в `/etc/network/interfaces`:  
   ```bash
   auto eth0
   iface eth0 inet manual
        bond-master bond0
   
   auto eth1
   iface eth1 inet manual
        bond-master bond0
   
   auto bond0
   iface bond0 inet dhcp
        bond-mode 1
        bond-miimon 100
        bond-primary eth0 eth1
   ```
   Если иcпользуется `systemd-networkd` то конфиг будет например в `/etc/systemd/network/25-bond.netdev`
   ```bash
   [NetDev]
        Name=bond1
        Kind=bond
   [Bond]
        Mode=802.3ad
        TransmitHashPolicy=layer3+4
        MIIMonitorSec=1s
        LACPTransmitRate=fast
   ```
5. В сети с маской /29 будет 6 хостов.
   ```bash
   vagrant@vagrant:~$ ipcalc 192.168.1.0/29
   Address:   192.168.1.0          11000000.10101000.00000001.00000 000
   Netmask:   255.255.255.248 = 29 11111111.11111111.11111111.11111 000
   Wildcard:  0.0.0.7              00000000.00000000.00000000.00000 111
   =>
   Network:   192.168.1.0/29       11000000.10101000.00000001.00000 000
   HostMin:   192.168.1.1          11000000.10101000.00000001.00000 001
   HostMax:   192.168.1.6          11000000.10101000.00000001.00000 110
   Broadcast: 192.168.1.7          11000000.10101000.00000001.00000 111
   Hosts/Net: 6                     Class C, Private Internet
   ```
   А подсетей /29 из сети с маской /24 будет 32.
   ```bash
   vagrant@vagrant:~$ ipcalc 192.168.1.0/24 29 | egrep Subnets
   Subnets after transition from /24 to /29
   Subnets:   32
   ```
   Примеры 29 подсети в сети 10.10.10.0/24
   ```bash
    1. 
   Network:   10.10.10.0/29
   HostMin:   10.10.10.1
   HostMax:   10.10.10.6
   Broadcast: 10.10.10.7
   Hosts/Net: 6                     Class A, Private Internet
    2.
   Network:   10.10.10.8/29        
   HostMin:   10.10.10.9           
   HostMax:   10.10.10.14          
   Broadcast: 10.10.10.15          
   Hosts/Net: 6                     Class A, Private Internet
    21.
   Network:   10.10.10.160/29      
   HostMin:   10.10.10.161         
   HostMax:   10.10.10.166         
   Broadcast: 10.10.10.167         
   Hosts/Net: 6                     Class A, Private Internet
   ```
6. Когда диапазоны 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 уже заняты, можно взять частные IP из подсети 100.64.0.0/10. Для 40-50 хостов возьмем 26-ю подсеть
   ```bash
   Netmask:   255.255.255.192 = 26 
   Network:   100.64.0.0/26        
   HostMin:   100.64.0.1           
   HostMax:   100.64.0.62          
   Broadcast: 100.64.0.63          
   Hosts/Net: 62                    Class A
   ```
7. Смотрим ARP таблицу в Linux
   ```bash
   vagrant@vagrant:~$ arp
   Address                  HWtype  HWaddress           Flags Mask            Iface
   10.0.2.3                 ether   52:54:00:12:35:03   C                     eth0
   _gateway                 ether   52:54:00:12:35:02   C                     eth0
   
   vagrant@vagrant:~$ ip neigh 
   10.0.2.3 dev eth0 lladdr 52:54:00:12:35:03 REACHABLE
   10.0.2.2 dev eth0 lladdr 52:54:00:12:35:02 REACHABLE
   ```
   Чтобы почистить кэш полностью
   ```bash
   vagrant@vagrant:~$ sudo ip neigh flush all
   ```
   Чтобы удалить только один нужный IP
   ```bash
   vagrant@vagrant:~$ sudo arp -d 10.0.2.3
   ```
   или так
   ```bash
   vagrant@vagrant:~$ sudo ip neigh del 10.0.2.3 dev eth0
   ```