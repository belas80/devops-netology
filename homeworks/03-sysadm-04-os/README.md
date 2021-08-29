# 3.4. Операционные системы, лекция 2  

1. Создаем простой Unit файл для node_exporter  
```bash
vagrant@vagrant:~$ cat /etc/systemd/system/node_exporter.service 
[Unit]
Description=Node Exporter

[Service]
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target  
```

Делаем релоад  

`vagrant@vagrant:~$ systemctl daemon-reload`  
```bash
vagrant@vagrant:~$ systemctl status node_exporter
● node_exporter.service - Node Exporter
     Loaded: loaded (/etc/systemd/system/node_exporter.service; disabled; vendor preset: enabled)
     Active: inactive (dead)
```

Включаем автозагрузку и стартуем node_exporter  
```bash
vagrant@vagrant:~$ systemctl enable node_exporter
vagrant@vagrant:~$ systemctl start node_exporter
vagrant@vagrant:~$ systemctl status node_exporter
● node_exporter.service - Node Exporter
     Loaded: loaded (/etc/systemd/system/node_exporter.service; enabled; vendor preset: enabled)
     Active: active (running) since Sun 2021-08-22 18:17:58 UTC; 3s ago
   Main PID: 1386 (node_exporter)
      Tasks: 4 (limit: 1112)
     Memory: 2.1M
     CGroup: /system.slice/node_exporter.service
             └─1386 /usr/local/bin/node_exporter

Aug 22 18:17:58 vagrant node_exporter[1386]: level=info ts=2021-08-22T18:17:58.658Z caller=node_exporter.go:115 colle>
Aug 22 18:17:58 vagrant node_exporter[1386]: level=info ts=2021-08-22T18:17:58.659Z caller=node_exporter.go:115 colle>
Aug 22 18:17:58 vagrant node_exporter[1386]: level=info ts=2021-08-22T18:17:58.659Z caller=node_exporter.go:115 colle>
Aug 22 18:17:58 vagrant node_exporter[1386]: level=info ts=2021-08-22T18:17:58.659Z caller=node_exporter.go:115 colle>
Aug 22 18:17:58 vagrant node_exporter[1386]: level=info ts=2021-08-22T18:17:58.659Z caller=node_exporter.go:115 colle>
Aug 22 18:17:58 vagrant node_exporter[1386]: level=info ts=2021-08-22T18:17:58.659Z caller=node_exporter.go:115 colle>
Aug 22 18:17:58 vagrant node_exporter[1386]: level=info ts=2021-08-22T18:17:58.659Z caller=node_exporter.go:115 colle>
Aug 22 18:17:58 vagrant node_exporter[1386]: level=info ts=2021-08-22T18:17:58.659Z caller=node_exporter.go:115 colle>
Aug 22 18:17:58 vagrant node_exporter[1386]: level=info ts=2021-08-22T18:17:58.661Z caller=node_exporter.go:199 msg=">
Aug 22 18:17:58 vagrant node_exporter[1386]: level=info ts=2021-08-22T18:17:58.662Z caller=tls_config.go:191 msg="TLS>
lines 1-19/19 (END)
```
Добавим возможность добавления опций через файл изменив блок `[Service]` добавив `EnvironmentFile`  
Файл юнита получится следующего содержания  

```bash
vagrant@vagrant:~$ systemctl cat node_exporter
# /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter

[Service]
EnvironmentFile=-/etc/default/node_exporter
ExecStart=/usr/local/bin/node_exporter $NODE_EXPORTER_OPTS

[Install]
WantedBy=multi-user.target
```

Для проверки в файл /etc/default/node_exporter прописал  
```bash
NODE_EXPORTER_OPTS=--collector.disable-defaults --collector.cpu
```

Проверим корректное завершение  

```
vagrant@vagrant:~$ systemctl stop node_exporter
vagrant@vagrant:~$ systemctl status node_exporter
● node_exporter.service - Node Exporter
     Loaded: loaded (/etc/systemd/system/node_exporter.service; enabled; vendor preset: enabled)
     Active: inactive (dead) since Sun 2021-08-22 19:00:29 UTC; 1s ago
    Process: 1641 ExecStart=/usr/local/bin/node_exporter (code=killed, signal=TERM)
   Main PID: 1641 (code=killed, signal=TERM)

Aug 22 19:00:14 vagrant node_exporter[1641]: level=info ts=2021-08-22T19:00:14.739Z caller=node_exporter.go:115 colle>
Aug 22 19:00:14 vagrant node_exporter[1641]: level=info ts=2021-08-22T19:00:14.739Z caller=node_exporter.go:115 colle>
Aug 22 19:00:14 vagrant node_exporter[1641]: level=info ts=2021-08-22T19:00:14.740Z caller=node_exporter.go:115 colle>
Aug 22 19:00:14 vagrant node_exporter[1641]: level=info ts=2021-08-22T19:00:14.740Z caller=node_exporter.go:115 colle>
Aug 22 19:00:14 vagrant node_exporter[1641]: level=info ts=2021-08-22T19:00:14.740Z caller=node_exporter.go:115 colle>
Aug 22 19:00:14 vagrant node_exporter[1641]: level=info ts=2021-08-22T19:00:14.740Z caller=node_exporter.go:199 msg=">
Aug 22 19:00:14 vagrant node_exporter[1641]: level=info ts=2021-08-22T19:00:14.741Z caller=tls_config.go:191 msg="TLS>
Aug 22 19:00:29 vagrant systemd[1]: Stopping Node Exporter...
Aug 22 19:00:29 vagrant systemd[1]: node_exporter.service: Succeeded.
Aug 22 19:00:29 vagrant systemd[1]: Stopped Node Exporter.
```

После ребута сервис так же запустился без ошибок.  

2. По умолчанию включены почти все метрики. Для базового мониторинга я бы выбрал  следующие метрики  

```bash
node_cpu_seconds_total{cpu="0",mode="idle"} 1760.39
node_cpu_seconds_total{cpu="0",mode="system"} 7.25
node_cpu_seconds_total{cpu="0",mode="user"} 5.6
node_cpu_seconds_total{cpu="1",mode="idle"} 1758.22
node_cpu_seconds_total{cpu="1",mode="system"} 7.42
node_cpu_seconds_total{cpu="1",mode="user"} 5.75
node_memory_MemFree_bytes 3.26893568e+08
node_memory_MemTotal_bytes 1.02868992e+09
node_filesystem_free_bytes{device="/dev/mapper/vgvagrant-root",fstype="ext4",mountpoint="/"} 6.3346028544e+10
node_filesystem_size_bytes{device="/dev/mapper/vgvagrant-root",fstype="ext4",mountpoint="/"} 6.5827115008e+10
node_network_receive_bytes_total{device="eth0"} 615601
node_network_transmit_bytes_total{device="eth0"} 647027
node_network_info{address="08:00:27:73:60:cf",broadcast="ff:ff:ff:ff:ff:ff",device="eth0",duplex="full",ifalias="",operstate="up"} 1
node_network_speed_bytes{device="eth0"} 1.25e+08
node_network_up{device="eth0"} 1
```

В файле опций можно написать  

```bash
NODE_EXPORTER_OPTS=--collector.disable-defaults --collector.cpu --collector.cpufreq --collector.filesystem --collector.meminfo --collector.netdev
```

3. Установка NetData и проброс порта с хоста были без затруднений. Пробовал установку как с помощью рекомендованного скрипта (``bash <(curl -Ss https://my-netdata.io/kickstart.sh)``), так и через (`sudo apt install -y netdata`).  
   Файлы конфигов и скриншот браузера с локальной машины. Все поднялось, проброс порта работает.  

```bash
vagrant@vagrant:~$ cat /etc/netdata/netdata.conf 
# NetData Configuration

# The current full configuration can be retrieved from the running
# server at the URL
#
#   http://localhost:19999/netdata.conf
#
# for example:
#
#   wget -O /etc/netdata/netdata.conf http://localhost:19999/netdata.conf
#

[global]
	run as user = netdata
	web files owner = root
	web files group = root
	# Netdata is not designed to be exposed to potentially hostile
	# networks. See https://github.com/netdata/netdata/issues/164
	bind socket to IP = 0.0.0.0
```

```bash
belyaev@MacBook-Air-Aleksandr devops-vagrant % cat Vagrantfile | grep -v -e #

Vagrant.configure("2") do |config|

  config.vm.box = "bento/ubuntu-20.04"

     config.vm.network "forwarded_port", guest: 19999, host: 19999

     config.vm.provider "virtualbox" do |vb|
       vb.memory = "1024"
       vb.cpus = 2
     end

end

```
![](/img/screenNedData.png)  

4. По выводу `dmesg`  ОС похоже понимает что запускается на виртуализации. В выводе, например, присутствуют сточки  

```bash
[    0.000000] DMI: innotek GmbH VirtualBox/VirtualBox, BIOS VirtualBox 12/01/2006
[    0.000000] Hypervisor detected: KVM
[    0.238722] Booting paravirtualized kernel on KVM
```

5. `fs.nr_open` - это количество открытых файлов на процесс. По умолчанию значение 1048576  

```bash
vagrant@vagrant:~$ sysctl -a --pattern fs.nr_open
fs.nr_open = 1048576
```

`man` нам говорит, что доступные параметры `sysctl` перечислены в `/proc/sys/`. Смотрим `man proc` или `man procfs`  

```bash
 /proc/sys/fs/nr_open (since Linux 2.6.25)
              This file imposes ceiling on the value to which the RLIMIT_NOFILE resource limit can be  raised  (see
              getrlimit(2)).   This  ceiling is enforced for both unprivileged and privileged process.  The default
              value in this file is 1048576.  (Before Linux 2.6.25, the ceiling for RLIMIT_NOFILE was hard-coded to
              the same value.)
```

Далее посмотрим `man getrlimit`  

```bash
RLIMIT_NOFILE
              This specifies a value one greater than the maximum file descriptor number that can be opened by this
              process.  Attempts (open(2), pipe(2), dup(2), etc.)  to exceed this limit  yield  the  error  EMFILE.
              (Historically, this limit was named RLIMIT_OFILE on BSD.)
```

Другой существующий лимит не позволяющий достичь этого числа это  

```bash
vagrant@vagrant:~$ ulimit -n
1024
vagrant@vagrant:~$ ulimit -a | grep open
open files                      (-n) 1024
vagrant@vagrant:~$ ulimit --help | grep "\-n"
      -n	the maximum number of open file descriptors
```

6. Запускаем sleep в отдельном неймспейсе  

```bash
root@vagrant:~# unshare --pid --fork --mount-proc sleep 1h &
[1] 2070

root@vagrant:~# ps aux | grep sleep
root        2070  0.0  0.0   8080   592 pts/0    S    18:34   0:00 unshare --pid --fork --mount-proc sleep 1h
root        2071  0.0  0.0   8076   528 pts/0    S    18:34   0:00 sleep 1h
root        2077  0.0  0.0   8900   736 pts/0    S+   18:35   0:00 grep --color=auto sleep

root@vagrant:~# nsenter --target 2071 --pid --mount

root@vagrant:/# ps aux
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.0  0.0   8076   528 pts/0    S    18:34   0:00 sleep 1h
root           2  0.1  0.5  10772  5028 pts/0    S    18:36   0:00 -bash
root          11  0.0  0.3  11492  3256 pts/0    R+   18:36   0:00 ps aux

root@vagrant:/# lsns 
        NS TYPE   NPROCS PID USER COMMAND
4026531835 cgroup      3   1 root sleep 1h
4026531837 user        3   1 root sleep 1h
4026531838 uts         3   1 root sleep 1h
4026531839 ipc         3   1 root sleep 1h
4026531992 net         3   1 root sleep 1h
4026532186 mnt         3   1 root sleep 1h
4026532187 pid         3   1 root sleep 1h
```

7. `:(){ :|:& };:` определяет функцию с именем `:` которая вызывает себя дважды (` :|: `) и уходит в фон (`&`). Бесконечный рекурсивный цикл который зарежется лимитом `ulimit -u` (ограничение количество процессов). Для наглядности, переименовав `:` в `bomb` можно записать ее так  

```bash
bomb()
{ 
    bomb | bomb & 
;
bomb
```

Судя по `dmesg`  

```bash
[   97.102715] cgroup: fork rejected by pids controller in /user.slice/user-1000.slice/session-3.scope
```

Отработал `pids controller` в `cgroup`, на ограничение количества процессов.  

```bash
 pids (since Linux 4.3; CONFIG_CGROUP_PIDS)
          This controller permits limiting the number of process that may be created in a cgroup (and its descendants).
```

Из man понял что `cgroups` это функция ядра, которая организовывает процессы в иерархические группы, использование которых различных типов ресурсов может быть ограничено и отслежено. Группировка реализована в основном коде ядра, а отслеживания и ограничения в наборе подсистем для каждого типа ресурса (CPU, Mem and so on).  

Изменить число создаваемых процессов в сессии можно так  
`ulimit -u 100`