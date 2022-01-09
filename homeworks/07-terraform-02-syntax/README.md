# 7.2. Облачные провайдеры и синтаксис Terraform.  

## Задача 1  

   Регистрация в aws и знакомство с основами  
   ![](img/aws_conf.png)  
   Создал группу `Admins-Terraform` с требуемыми правами, создал и довавил в эту группу пользователя `AdminTF`  
   ![](img/aws_list.png)  
   Далее все действия выполнял от этого пользователя.  
   
## Задача 2  

   Создание aws ec2 через терраформ  
   ![](img/aws_apply.png)  
   Вход по ssh на созданный инстанс ec2  
   ![](img/aws_login.png)  
   Удаление созданных ресурсов через терраформ  
   ![](img/aws_destroy.png)  
   Свой образ ami можно создать с помощью Packer.  
   [Исходники конфигурации терраформа AWS.](https://github.com/belas80/devops-netology/tree/main/homeworks/07-terraform-02-syntax/src/terraform/aws)
   [Исходники конфигурации терраформа Yandex Cloud.](https://github.com/belas80/devops-netology/tree/main/homeworks/07-terraform-02-syntax/src/terraform/yc)