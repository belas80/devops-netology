# 7.1. Инфраструктура как код  

## Задача 1  

   1. В рамках совещания выясняем подробности о проекте  
      1. Для базовых ресурсов (вирт. машины, сеть, пользователи, ключи доступа и т.д.) инфраструктура будет не изменяемой 
      (Terraform). А для сервиса, учитывая еще и то, что есть вероятность большого количества небольших релизов, 
      тестирований интеграций, откатов, доработок, тип будет изменяемый с помощью Ansible скриптов. Т.е. будем использовать 
      оба типа инфраструктуры.  
      2. По легенде, в компании уже используются Terraform и Ansible, которым не требуется выделенный центральный сервер. 
      Предполагаю что будем использовать именно их, так что центрального сервера не будет. Это лишняя работа.  
      3. Terraform и Ansible работают без агентов. Агенты не нужны.  
      4. Будут использованы и средства управления конфигурацией (Ansible) и инициализации ресурсов (Terraform).  
   2. Из уже используемых инструментов я бы использовал 
      * Packer - для создания базового образа вирт. машин, 
      * Terraform - создание ресурсов из подготовленного пакером образа, 
      * Ansible - для установки нашего сервиса и зависимостей на наши созданные терраформом ресурсы, 
      * Docker - разработчики привыкли использовать его, вероятно наша прилага будет в нем, 
      * K8s - как средство оркестрации докер контейнеров, 
      * ну и Teamcity как CI инструмент.  
   3. Перечисленные инструменты уже и так хорошо себя зарекомендовали, имеют огромное сообщество и уже используются в 
   компании, а над проектом работу нужно начать уже сегодня. Не стал бы рассматривать возможность внедрения новых 
   инструментов. Используемых вполне достаточно для этого проекта.  

## Задача 2  

   Установка Terraform с помощью brew  
   ```bash
   belyaev@MacBook-Air-Aleksandr ~ % terraform --version
   Terraform v1.1.2
   on darwin_amd64
   belyaev@MacBook-Air-Aleksandr ~ % brew list terraform 
   /usr/local/Cellar/terraform/1.1.2/bin/terraform
   belyaev@MacBook-Air-Aleksandr ~ %  
   ```

## Задача 3  

   Одновременное использование разных версий Terraform.  
   Терраформ поставляется в виде одно бинарника, поэтому, как вариант, его просто можно запустить из определенной директории.  
   ```bash
   belyaev@MacBook-Air-Aleksandr ~ % terraform --version                  
   Terraform v1.1.2
   on darwin_amd64
   belyaev@MacBook-Air-Aleksandr ~ % 
   belyaev@MacBook-Air-Aleksandr ~ % ./terraform/1.1.1/terraform --version
   Terraform v1.1.1
   on darwin_amd64
   
   Your version of Terraform is out of date! The latest version
   is 1.1.2. You can update by downloading from https://www.terraform.io/downloads.html
   belyaev@MacBook-Air-Aleksandr ~ %                                      
   belyaev@MacBook-Air-Aleksandr ~ % ./terraform/1.1.0/terraform --version
   Terraform v1.1.0
   on darwin_amd64
   
   Your version of Terraform is out of date! The latest version
   is 1.1.2. You can update by downloading from https://www.terraform.io/downloads.html
   belyaev@MacBook-Air-Aleksandr ~ % 
   ```
   Можно создать симлинки для нужных версий в `/usr/local/bin`, либо заменять по необходимости симлинк созданный brew, 
   например  
   ```bash
   belyaev@MacBook-Air-Aleksandr ~ % ls -l /usr/local/bin/terraform
   lrwxr-xr-x  1 belyaev  admin  39  6 янв 14:46 /usr/local/bin/terraform -> ../Cellar/terraform/1.1.2/bin/terraform
   belyaev@MacBook-Air-Aleksandr ~ % 
   belyaev@MacBook-Air-Aleksandr ~ % brew unlink terraform                                     
   Unlinking /usr/local/Cellar/terraform/1.1.2... 1 symlinks removed.
   belyaev@MacBook-Air-Aleksandr ~ % 
   belyaev@MacBook-Air-Aleksandr ~ % ln -s ~/terraform/1.1.1/terraform /usr/local/bin/terraform
   belyaev@MacBook-Air-Aleksandr ~ % 
   belyaev@MacBook-Air-Aleksandr ~ % ls -l /usr/local/bin/terraform                            
   lrwxr-xr-x  1 belyaev  admin  40  6 янв 14:47 /usr/local/bin/terraform -> /Users/belyaev/terraform/1.1.1/terraform
   belyaev@MacBook-Air-Aleksandr ~ % 
   belyaev@MacBook-Air-Aleksandr ~ % terraform --version
   Terraform v1.1.1
   on darwin_amd64
   
   Your version of Terraform is out of date! The latest version
   is 1.1.2. You can update by downloading from https://www.terraform.io/downloads.html
   belyaev@MacBook-Air-Aleksandr ~ % 
   ```
   Вернем обратно  
   ```bash
   belyaev@MacBook-Air-Aleksandr ~ % rm /usr/local/bin/terraform                    
   belyaev@MacBook-Air-Aleksandr ~ % 
   belyaev@MacBook-Air-Aleksandr ~ % brew link terraform      
   Linking /usr/local/Cellar/terraform/1.1.2... 1 symlinks created.
   belyaev@MacBook-Air-Aleksandr ~ % terraform --version
   Terraform v1.1.2
   on darwin_amd64
   belyaev@MacBook-Air-Aleksandr ~ %    
   ```
   Для удобства можем автоматизировать этот процесс простеньким bash скриптом  
   ```bash
   #!/usr/bin/env bash
   
   version=$1
   
   if [[ $version = "brew" ]]
   then
       rm /usr/local/bin/terraform
       brew link terraform
   else
       brew unlink terraform
       ln -sf ~/terraform/$version/terraform /usr/local/bin/terraform
   fi   
   ```
   Так же, для удобного переключения между версиями, можно воспользоваться готовой утилитой например [tfenv](https://github.com/tfutils/tfenv)