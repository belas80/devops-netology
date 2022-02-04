# 7.6. Написание собственных провайдеров для Terraform.  

## Задача 1.  

   1. Все доступные `resource` и `data_source` перечислены в файле `provider.go` 
      [resource](https://github.com/hashicorp/terraform-provider-aws/blob/61c61be9ddad3ad5e6d8368d23ee12b0f674a566/internal/provider/provider.go#L789) 
      и [data_source](https://github.com/hashicorp/terraform-provider-aws/blob/61c61be9ddad3ad5e6d8368d23ee12b0f674a566/internal/provider/provider.go#L376).
   2. Для ресурса `aws_sqs_queue` параметр `name` конфликтует с параметром `name_prefix`. Это указано [здесь](https://github.com/hashicorp/terraform-provider-aws/blob/9a5875faab6b8732d7887438d285e43f253adb43/internal/service/sqs/queue.go#L87).
   3. Максимальная длинна имени 80 символов, это видно по регулярным выражениям [здесь](https://github.com/hashicorp/terraform-provider-aws/blob/9a5875faab6b8732d7887438d285e43f253adb43/internal/service/sqs/queue.go#L424).
   4. Ну и само регулярное выражение по ссылке выше, их два. Большие и малые буквы алфавита, цифры от 0 до 9, подчеркивание
      и знак минус, а так же, если указан параметр `fifo_queue` в `true`, то к имени добавляется окончание `.fifo`.  

