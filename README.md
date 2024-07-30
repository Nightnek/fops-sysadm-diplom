#  Курсовая работа на профессии "DevOps-инженер с нуля"

Содержание
==========
* [Задача](#Задача)
* [Инфраструктура](#Инфраструктура)
    * [Сайт](#Сайт)
    * [Мониторинг](#Мониторинг)
    * [Логи](#Логи)
    * [Сеть](#Сеть)
    * [Резервное копирование](#Резервное-копирование)

---------
## Задача
Ключевая задача — разработать отказоустойчивую инфраструктуру для сайта, включающую мониторинг, сбор логов и резервное копирование основных данных. Инфраструктура должна размещаться в [Yandex Cloud](https://cloud.yandex.com/).

**Примечание**: в курсовой работе используется система мониторинга Prometheus. Вместо Prometheus вы можете использовать Zabbix. Задание для курсовой работы с использованием Zabbix находится по [ссылке](https://github.com/netology-code/fops-sysadm-diplom/blob/diplom-zabbix/README.md).

**Перед началом работы над дипломным заданием изучите [Инструкция по экономии облачных ресурсов](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD).**   

## Инфраструктура
Для развёртки инфраструктуры используйте Terraform и Ansible. 

````
Файлы конфигурации приложены к репозиторию.

````

Параметры виртуальной машины (ВМ) подбирайте по потребностям сервисов, которые будут на ней работать. 

Ознакомьтесь со всеми пунктами из этой секции, не беритесь сразу выполнять задание, не дочитав до конца. Пункты взаимосвязаны и могут влиять друг на друга.

### Сайт
Создайте две ВМ в разных зонах, установите на них сервер nginx, если его там нет. ОС и содержимое ВМ должно быть идентичным, это будут наши веб-сервера.

![image](https://github.com/user-attachments/assets/9719055a-c0f4-4b37-992a-65f1d20358df)


Используйте набор статичных файлов для сайта. Можно переиспользовать сайт из домашнего задания.

Создайте [Target Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/target-group), включите в неё две созданных ВМ.

![image](https://github.com/user-attachments/assets/500bdcc3-fe40-4d96-8ae6-e9e37b44eeaf)

Создайте [Backend Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/backend-group), настройте backends на target group, ранее созданную. Настройте healthcheck на корень (/) и порт 80, протокол HTTP.

![image](https://github.com/user-attachments/assets/b8c5ae6e-7290-4279-acd3-609ddcc2329f)


Создайте [HTTP router](https://cloud.yandex.com/docs/application-load-balancer/concepts/http-router). Путь укажите — /, backend group — созданную ранее.

![image](https://github.com/user-attachments/assets/e7ba791b-d6a3-4356-a836-17c7215868c2)

Создайте [Application load balancer](https://cloud.yandex.com/en/docs/application-load-balancer/) для распределения трафика на веб-сервера, созданные ранее. Укажите HTTP router, созданный ранее, задайте listener тип auto, порт 80.

![image](https://github.com/user-attachments/assets/fea5eaa7-19df-424f-992d-ce20b21b88a8)

Протестируйте сайт
`curl -v <публичный IP балансера>:80` 

### Сайт доступен по адресу: [http://51.250.41.122/](http://51.250.41.122/)

![image](https://github.com/user-attachments/assets/74cd110c-909d-46fb-b707-1b6be42de111)


### Мониторинг
Создайте ВМ, разверните на ней Prometheus. На каждую ВМ из веб-серверов установите Node Exporter и [Nginx Log Exporter](https://github.com/martin-helmich/prometheus-nginxlog-exporter). Настройте Prometheus на сбор метрик с этих exporter.

![image](https://github.com/user-attachments/assets/3dca8b9f-dad0-44b5-a4e9-7639b453824a)

Создайте ВМ, установите туда Grafana. Настройте её на взаимодействие с ранее развернутым Prometheus. Настройте дешборды с отображением метрик, минимальный набор — Utilization, Saturation, Errors для CPU, RAM, диски, сеть, http_response_count_total, http_response_size_bytes. Добавьте необходимые [tresholds](https://grafana.com/docs/grafana/latest/panels/thresholds/) на соответствующие графики.


### Ссылка на отчет Grafana: http://158.160.57.60:3000/d/fdsnceuejak8wc/webservers-dashboard?orgId=1


### Логи
Cоздайте ВМ, разверните на ней Elasticsearch. Установите filebeat в ВМ к веб-серверам, настройте на отправку access.log, error.log nginx в Elasticsearch.

Создайте ВМ, разверните на ней Kibana, сконфигурируйте соединение с Elasticsearch.


### Отчет Kibana можно найти по ссылке: [http://51.250.66.249:5601/app/discover#/view/7183f57e-c988-4836-ba82-c00eaa8cc55a?_g=()](http://51.250.66.249:5601/app/discover#/view/7183f57e-c988-4836-ba82-c00eaa8cc55a?_g=())
````
Логин: kibana
Пароль: 2ln2mIJ-Ri2Vicw0ht_d

````

### Сеть
Разверните один VPC. Сервера web, Prometheus, Elasticsearch поместите в приватные подсети. Сервера Grafana, Kibana, application load balancer определите в публичную подсеть.
![image](https://github.com/user-attachments/assets/ae46c9a3-5a2d-496e-a86a-568a4d91465d)
![image](https://github.com/user-attachments/assets/001a2664-59ca-4026-ac63-d899e78d632a)
![image](https://github.com/user-attachments/assets/906e6ca9-47a5-4bf6-9cb6-cb17c9c85a6b)


Настройте [Security Groups](https://cloud.yandex.com/docs/vpc/concepts/security-groups) соответствующих сервисов на входящий трафик только к нужным портам.
![image](https://github.com/user-attachments/assets/689e3f70-1089-470e-8aa9-2455ffb031fd)
![image](https://github.com/user-attachments/assets/56218985-f6df-4609-a386-291f2de1397f)
![image](https://github.com/user-attachments/assets/b779ef06-d065-4980-b6c8-391ba7fb9fbb)

Настройте ВМ с публичным адресом, в которой будет открыт только один порт — ssh. Настройте все security groups на разрешение входящего ssh из этой security group. Эта вм будет реализовывать концепцию bastion host. Потом можно будет подключаться по ssh ко всем хостам через этот хост.
![image](https://github.com/user-attachments/assets/f31fcc1e-f2f3-43d1-96c5-c31859db305b)
![image](https://github.com/user-attachments/assets/a2ae7345-9c46-4ee3-8dee-095c00fa16da)
![image](https://github.com/user-attachments/assets/1ddab878-14aa-44b6-a3c2-ba293dfbcdb5)


### Резервное копирование
Создайте snapshot дисков всех ВМ. Ограничьте время жизни snaphot в неделю. Сами snaphot настройте на ежедневное копирование.


![image](https://github.com/user-attachments/assets/2bddb1c0-9766-46d4-adee-913c21844877)

![image](https://github.com/user-attachments/assets/301ec8e5-8447-4d26-91d5-79fbf3f5b7c7)

