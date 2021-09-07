# 3.5. Файловые системы  
1. Разрежённый файл (англ. sparse file) — файл, в котором последовательности нулевых байтов заменены на информацию об этих последовательностях (список дыр). Создадим разреженный файл  

    ```bash
   vagrant@vagrant:~$ dd if=/dev/zero of=./sparse-file bs=1 count=0 seek=1G
   0+0 records in
   0+0 records out
   0 bytes copied, 0.000258511 s, 0.0 kB/s 
   ```
   
1. Файлы являющиеся жесткой ссылкой на один объект не могут иметь разные права доступа и владельца, так как информация о правах доступа привязываются к объекту inode, а не к жесткой ссылке. Hardlink это по сути тот же файл на который он ссылается.  
1. Создаем виртуальную машину по конфигу из задания. На выходе получаем два дополнительных диска `sdb` и `sdc`.
    ```bash
    vagrant@vagrant:~$ lsblk 
    NAME                 MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
    sda                    8:0    0   64G  0 disk 
    ├─sda1                 8:1    0  512M  0 part /boot/efi
    ├─sda2                 8:2    0    1K  0 part 
    └─sda5                 8:5    0 63.5G  0 part 
      ├─vgvagrant-root   253:0    0 62.6G  0 lvm  /
      └─vgvagrant-swap_1 253:1    0  980M  0 lvm  [SWAP]
    sdb                    8:16   0  2.5G  0 disk 
    sdc                    8:32   0  2.5G  0 disk 
   ```

1. Разбил первый `sdb` диск на два с помощью `fdisk`  
   ```bash
   vagrant@vagrant:~$ lsblk | grep sdb
   sdb                    8:16   0  2.5G  0 disk 
   ├─sdb1                 8:17   0  500M  0 part 
   └─sdb2                 8:18   0    2G  0 part 
   root@vagrant:~# fdisk -l /dev/sdb
   Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors
   Disk model: VBOX HARDDISK   
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 512 bytes / 512 bytes
   Disklabel type: dos
   Disk identifier: 0xe3b63c75
   
   Device     Boot   Start     End Sectors  Size Id Type
   /dev/sdb1          2048 1026047 1024000  500M 83 Linux
   /dev/sdb2       1026048 5242879 4216832    2G 83 Linux
   ```
   
1. С помощью `sfdisk` перенесем таблицу разделов на второй диск  
   ```bash
   root@vagrant:~# sfdisk -d /dev/sdb | sfdisk /dev/sdc
   Checking that no-one is using this disk right now ... OK
   
   Disk /dev/sdc: 2.51 GiB, 2684354560 bytes, 5242880 sectors
   Disk model: VBOX HARDDISK   
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 512 bytes / 512 bytes
   
   >>> Script header accepted.
   >>> Script header accepted.
   >>> Script header accepted.
   >>> Script header accepted.
   >>> Created a new DOS disklabel with disk identifier 0xe3b63c75.
   /dev/sdc1: Created a new partition 1 of type 'Linux' and of size 500 MiB.
   /dev/sdc2: Created a new partition 2 of type 'Linux' and of size 2 GiB.
   /dev/sdc3: Done.
   
   New situation:
   Disklabel type: dos
   Disk identifier: 0xe3b63c75
   
   Device     Boot   Start     End Sectors  Size Id Type
   /dev/sdc1          2048 1026047 1024000  500M 83 Linux
   /dev/sdc2       1026048 5242879 4216832    2G 83 Linux
   
   The partition table has been altered.
   Calling ioctl() to re-read partition table.
   Syncing disks.
   
   root@vagrant:~# fdisk -l /dev/sd[bc] | grep sd[bc]
   Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors
   /dev/sdb1          2048 1026047 1024000  500M 83 Linux
   /dev/sdb2       1026048 5242879 4216832    2G 83 Linux
   Disk /dev/sdc: 2.51 GiB, 2684354560 bytes, 5242880 sectors
   /dev/sdc1          2048 1026047 1024000  500M 83 Linux
   /dev/sdc2       1026048 5242879 4216832    2G 83 Linux
   ```
1. Соберем RAID1 на дисках 2ГБ  
   ```bash
   root@vagrant:~# mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sd[bc]2
   mdadm: Note: this array has metadata at the start and
       may not be suitable as a boot device.  If you plan to
       store '/boot' on this device please ensure that
       your boot-loader understands md/v1.x metadata, or use
       --metadata=0.90
   Continue creating array? yes
   mdadm: Defaulting to version 1.2 metadata
   mdadm: array /dev/md0 started.
   
   root@vagrant:~# mdadm --query /dev/md0
   /dev/md0: 2.01GiB raid1 2 devices, 0 spares. Use mdadm --detail for more detail.
   
   root@vagrant:~# lsblk | egrep "(sd[bc]|md)"
   sdb                    8:16   0  2.5G  0 disk  
   ├─sdb1                 8:17   0  500M  0 part  
   └─sdb2                 8:18   0    2G  0 part  
     └─md0                9:0    0    2G  0 raid1 
   sdc                    8:32   0  2.5G  0 disk  
   ├─sdc1                 8:33   0  500M  0 part  
   └─sdc2                 8:34   0    2G  0 part  
     └─md0                9:0    0    2G  0 raid1 
   root@vagrant:~# 
   
   ```
   
1. Соберем RAID0 на оставшихся 500ГБ  
   ```bash
   root@vagrant:~# mdadm --create /dev/md1 --level=0 --raid-devices=2 /dev/sd[bc]1
   mdadm: /dev/sdb1 appears to be part of a raid array:
          level=raid1 devices=2 ctime=Fri Sep  3 16:39:04 2021
   mdadm: /dev/sdc1 appears to be part of a raid array:
          level=raid1 devices=2 ctime=Fri Sep  3 16:39:04 2021
   Continue creating array? yes
   mdadm: Defaulting to version 1.2 metadata
   mdadm: array /dev/md1 started.
   
   root@vagrant:~# mdadm --query /dev/md[10]
   /dev/md0: 2.01GiB raid1 2 devices, 0 spares. Use mdadm --detail for more detail.
   /dev/md1: 996.00MiB raid0 2 devices, 0 spares. Use mdadm --detail for more detail.
   ```

1. Создаем `PV` на `md`  
   ```bash
   root@vagrant:~# pvcreate /dev/md0 /dev/md1
     Physical volume "/dev/md0" successfully created.
     Physical volume "/dev/md1" successfully created.
     
   root@vagrant:~# pvs
     PV         VG        Fmt  Attr PSize   PFree  
     /dev/md0             lvm2 ---   <2.01g  <2.01g
     /dev/md1             lvm2 ---  996.00m 996.00m
     /dev/sda5  vgvagrant lvm2 a--  <63.50g      0
   ```
1. Создадим общую `VG` на этих `PV`  
   ```bash
   root@vagrant:~# vgcreate vg1 /dev/md[01]
     Volume group "vg1" successfully created
   
   root@vagrant:~# vgs
     VG        #PV #LV #SN Attr   VSize   VFree
     vg1         2   0   0 wz--n-   2.97g 2.97g
     vgvagrant   1   2   0 wz--n- <63.50g    0 
   ```
1. Создаем `LV` 100Мб на RAID0  
   ```bash
   root@vagrant:~# lvcreate -L 100M vg1 /dev/md1
     Logical volume "lvol0" created.
   
   root@vagrant:~# lvs
     LV     VG        Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
     lvol0  vg1       -wi-a----- 100.00m                                                    
     root   vgvagrant -wi-ao---- <62.54g                                                    
     swap_1 vgvagrant -wi-ao---- 980.00m   
     
   root@vagrant:~# lsblk | egrep "(sd[bc]|md|vg1)"
   sdb                    8:16   0  2.5G  0 disk  
   ├─sdb1                 8:17   0  500M  0 part  
   │ └─md1                9:1    0  996M  0 raid0 
   │   └─vg1-lvol0      253:2    0  100M  0 lvm   
   └─sdb2                 8:18   0    2G  0 part  
     └─md0                9:0    0    2G  0 raid1 
   sdc                    8:32   0  2.5G  0 disk  
   ├─sdc1                 8:33   0  500M  0 part  
   │ └─md1                9:1    0  996M  0 raid0 
   │   └─vg1-lvol0      253:2    0  100M  0 lvm   
   └─sdc2                 8:34   0    2G  0 part  
     └─md0                9:0    0    2G  0 raid1 
   ```
1. Создадим ФС ext4  
   ```bash
   root@vagrant:~# mkfs.ext4 /dev/vg1/lvol0
   mke2fs 1.45.5 (07-Jan-2020)
   Creating filesystem with 25600 4k blocks and 25600 inodes
   
   Allocating group tables: done                            
   Writing inode tables: done                            
   Creating journal (1024 blocks): done
   Writing superblocks and filesystem accounting information: done
   ```
1. Смонтируем в `/tmp/new` 
   ```bash
   root@vagrant:~# mount /dev/vg1/lvol0 /tmp/new
   ```
1. Помещаем тестовый файл  
   ```bash
   root@vagrant:~# wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz
   --2021-09-03 17:54:20--  https://mirror.yandex.ru/ubuntu/ls-lR.gz
   Resolving mirror.yandex.ru (mirror.yandex.ru)... 213.180.204.183, 2a02:6b8::183
   Connecting to mirror.yandex.ru (mirror.yandex.ru)|213.180.204.183|:443... connected.
   HTTP request sent, awaiting response... 200 OK
   Length: 21042453 (20M) [application/octet-stream]
   Saving to: ‘/tmp/new/test.gz’
   
   /tmp/new/test.gz              100%[================================================>]  20.07M  5.35MB/s    in 4.6s    
   
   2021-09-03 17:54:25 (4.33 MB/s) - ‘/tmp/new/test.gz’ saved [21042453/21042453]
   ```
1. Вывод `lsblk`
   ```bash
   root@vagrant:~# lsblk 
   NAME                 MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
   sda                    8:0    0   64G  0 disk  
   ├─sda1                 8:1    0  512M  0 part  /boot/efi
   ├─sda2                 8:2    0    1K  0 part  
   └─sda5                 8:5    0 63.5G  0 part  
     ├─vgvagrant-root   253:0    0 62.6G  0 lvm   /
     └─vgvagrant-swap_1 253:1    0  980M  0 lvm   [SWAP]
   sdb                    8:16   0  2.5G  0 disk  
   ├─sdb1                 8:17   0  500M  0 part  
   │ └─md1                9:1    0  996M  0 raid0 
   │   └─vg1-lvol0      253:2    0  100M  0 lvm   /tmp/new
   └─sdb2                 8:18   0    2G  0 part  
     └─md0                9:0    0    2G  0 raid1 
   sdc                    8:32   0  2.5G  0 disk  
   ├─sdc1                 8:33   0  500M  0 part  
   │ └─md1                9:1    0  996M  0 raid0 
   │   └─vg1-lvol0      253:2    0  100M  0 lvm   /tmp/new
   └─sdc2                 8:34   0    2G  0 part  
     └─md0                9:0    0    2G  0 raid1 
   ```
1. Целостность файла  
   ```bash
   root@vagrant:~# gzip -t /tmp/new/test.gz
   root@vagrant:~# echo $?
   0
   ```
1. Переместим  `PV` на RAID1  
   ```bash
   root@vagrant:~# pvmove -n lvol0 /dev/md1 /dev/md0
     /dev/md1: Moved: 20.00%
     /dev/md1: Moved: 100.00%
   root@vagrant:~# 
   root@vagrant:~# lsblk | egrep "(sd[bc]|md|vg1)"
   sdb                    8:16   0  2.5G  0 disk  
   ├─sdb1                 8:17   0  500M  0 part  
   │ └─md1                9:1    0  996M  0 raid0 
   └─sdb2                 8:18   0    2G  0 part  
     └─md0                9:0    0    2G  0 raid1 
       └─vg1-lvol0      253:2    0  100M  0 lvm   /tmp/new
   sdc                    8:32   0  2.5G  0 disk  
   ├─sdc1                 8:33   0  500M  0 part  
   │ └─md1                9:1    0  996M  0 raid0 
   └─sdc2                 8:34   0    2G  0 part  
     └─md0                9:0    0    2G  0 raid1 
       └─vg1-lvol0      253:2    0  100M  0 lvm   /tmp/new
   ```
1. Делаем `fail`  
   ```bash
   root@vagrant:~# mdadm --fail /dev/md0 /dev/sdc2
   mdadm: set /dev/sdc2 faulty in /dev/md0
   
   root@vagrant:~# cat /proc/mdstat 
   Personalities : [linear] [multipath] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10] 
   md1 : active raid0 sdc1[1] sdb1[0]
         1019904 blocks super 1.2 512k chunks
         
   md0 : active raid1 sdc2[1](F) sdb2[0]
         2105344 blocks super 1.2 [2/1] [U_]
   ```
1. Вывод `dmesg`  
   ```bash
   [ 6215.385989] md/raid1:md0: Disk failure on sdc2, disabling device.
                  md/raid1:md0: Operation continuing on 1 devices.
   ```
1. И снова проверяем целостность файла  
   ```bash
   root@vagrant:~# gzip -t /tmp/new/test.gz
   root@vagrant:~# echo $?
   0
   ```
