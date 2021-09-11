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
4. 