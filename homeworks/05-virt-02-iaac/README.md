# 5.2. Применение принципов IaaC в работе с виртуальными машинами  

## Задача 1   

   - Основные преимущества IaaC это скорость вывода продукта на рынок, стабильность среды которая уменьшает риски при 
   каких либо произвольных изменениях, т.е. устраняет дрейф конфигураций, а так же более эффективная разработка за счет 
   упрощения предоставления инфраструктуры, ее согласованности и целостности, которая разворачивается практически за 
   один шаг.
   - Главным IaaC является принцип идемпотентности. Свойство объекта или операции, при многократном вызове которой 
   возвращается один и тот же результат.
   
## Задача 2

   - Главное отличие Ansible от других систем в том, что он использует существующую SSH инфраструктуру и не требует 
   установки отдельной инфраструктуры открытых ключей PKI.
   - Pull метод кажется более надежным. Когда агенты целевых хостов сами методично по расписанию запрашивают конфиги и 
   сверяют дифы, это действительно придает больше уверенности.

## Задача 3  

   ```bash
   # Вывод версии VirtualBox
   belyaev@MacBook-Air-Aleksandr ~ % VirtualBox --help
   Oracle VM VirtualBox VM Selector v6.1.26
   (C) 2005-2021 Oracle Corporation
   All rights reserved.
   
   # Версия Vagrant
   belyaev@MacBook-Air-Aleksandr ~ % vagrant --version
   Vagrant 2.2.18
   
   # Ansible
   belyaev@MacBook-Air-Aleksandr ~ % ansible --version
   ansible [core 2.11.6] 
     config file = None
     configured module search path = ['/Users/belyaev/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
     ansible python module location = /usr/local/Cellar/ansible/4.7.0_1/libexec/lib/python3.10/site-packages/ansible
     ansible collection location = /Users/belyaev/.ansible/collections:/usr/share/ansible/collections
     executable location = /usr/local/bin/ansible
     python version = 3.10.0 (default, Oct 13 2021, 06:45:00) [Clang 13.0.0 (clang-1300.0.29.3)]
     jinja version = 3.0.2
     libyaml = True
   ```

## Задача 4

