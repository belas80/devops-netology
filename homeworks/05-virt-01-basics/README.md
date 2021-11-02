# 5.1. Введение в виртуализацию. Типы и функции гипервизоров. Обзор рынка вендоров и областей применения.  
1. Основное отличие полной (аппаратной) виртуализации от паравиртуализации состоит в том, что операционная система 
и является гипервизором, т.е. это оптимизированное готовое решение которое устанавливается на голое железо. 
Паравиртуализация это когда гипервизор в виде отдельной программы (сервиса) устанавливается на какую либо ОС. Оба типа
виртуализируют оборудование для гостевых машин. Виртуализация на основе ОС это когда сама хостовая ОС отвечает за 
разделение ресурсов гостевых систем, т.е. по сути нет отдельного слоя гипервизора. Изоляция происходит на уровне ядра
ОС, поэтому отсутствует виртуальное оборудование и используется реальное хостовой машины. Это так называемая технология 
контейнеризации, например LXC или Docker.  
2. Для высоконагруженной базы данных, чувствительной к отказу, я бы выбрал физические сервера, чтобы избежать потерю 
ресурсов на гипервизор.  
Web-приложениям отдал бы предпочтение виртуализации уровня ОС (контейнерам). Они быстро разворачиваются, хорошо 
маштабируются, поддержка и обновления просты.  
Windows системы для бухгалтерии выберу паравиртуализацию Hyper-V. Во-первых он родной для Windows систем, во-вторых, 
паравиртуализации будет достаточно, особо не требуется высокой маштабируемости, плотности и нагрузки. Предполагаю что 
это обычно 1С, возможно в связке с RDS и сетевая шара (File server). К тому же он бесплатный и достаточно прост в 
развертывании и обслуживании.  
Для высокопроизводительных расчетов на GPU, думаю выбрал бы физические сервера. Опять же руководствуясь тем, что 
промежуточный слой в виде гипервизора может повлиять на производительность. Хотя технологии развиваются и например 
компания VMWare нам говорит что их ESXi снижает скорость вычислений GPU всего на 3%, что в принципе может быть 
приемлемым. Может быть имеет смысл протестировать под конкретную задачу.  
3. Сценарии:
   1. 100 виртуальных машин на базе Linux и Windows, общие задачи, нет особых требований. Преимущественно Windows based 
   инфраструктура, требуется реализация программных балансировщиков нагрузки, репликации данных и автоматизированного 
   механизма создания резервных копий.  
        * Подойдет аппаратная виртуализация на базе VMWare. Тут есть все, и балансировка и репликация и множество решений
        по резервному копированию, например Veeam Backup.  
   2. Требуется наиболее производительное бесплатное open source решение для виртуализации небольшой (20-30 серверов) 
   инфраструктуры на базе Linux и Windows виртуальных машин.  
        * KVM. Работает и с linux и с windows, а так же считается более производительным, так как является нативным для 
        большинства современных ядер Linux.  
   3. Необходимо бесплатное, максимально совместимое и производительное решение для виртуализации Windows 
   инфраструктуры.  
        * Hyper-V. Родной гипервизор от Microsoft. Бесплатное, максимально совместимое и наиболее производительное для 
        Windows.  
   4. Необходимо рабочее окружение для тестирования программного продукта на нескольких дистрибутивах Linux.  
        * Думаю для этих целей хорошо подойдут облачные провайдеры IaaS, например Amazon AWS. Уже готовое решение для 
        развертывания любого окружения, есть API для автоматизации создания и изменения ресурсов, а также более 
        экономично по сравнению с покупкой и обслуживанием собственного железа. Конечно, если есть определенные 
        требования по безопасности, которые не позволяют использовать публичное облако, то подойдет любой open source 
        гипервизор, например KVM или Xen, где можно развернуть к примеру OpenStack.  
4. 