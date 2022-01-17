# 7.3. Основы и принцип работы Терраформ  

## Задача 1. Создадим бэкэнд в S3  

   Cоздание S3 бакета:  
   ```bash
   belyaev@MacBook-Air-Aleksandr ~ % aws s3 mb s3://tf-mystates
   make_bucket: tf-mystates
   ```
   Для регистрации бэкэнда создадим в проекте файл `backend.tf` следующего содержимого:  
   ```terraform
   terraform {
     backend "s3" {
       bucket = "tf-mystates"
       key    = "main/terraform.tfstate"
       region = "eu-central-1"
     }
   }
   ```

## Задача 2. Инициализируем проект и создаем воркспейсы.  

   