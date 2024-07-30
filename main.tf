terraform {
  required_providers {
    yandex = {
        source = "yandex-cloud/yandex"
    }
  }
}

variable "yandex_cloud_token" {
  type = string
  description = "Введите токен"
}

provider "yandex" {
  token = var.yandex_cloud_token
  cloud_id = "b1gua5vm4htrvegtvhce"
  folder_id = "b1ghuka5aa58723hlijr"
}

resource "yandex_vpc_network" "web_network" {
  name = "net_web"
}

resource "yandex_vpc_subnet" "web_bastionSN_b" {
  name = "web_bastion_b"
  zone = "ru-central1-b"
  network_id = yandex_vpc_network.web_network.id
  v4_cidr_blocks = ["192.168.3.0/24"]
}

resource "yandex_vpc_subnet" "web_SN" {
  name = "web_a"
  zone = "ru-central1-a"
  network_id = yandex_vpc_network.web_network.id
  v4_cidr_blocks = ["192.168.1.0/24"]
}

resource "yandex_vpc_subnet" "web_pub_SN" {
  name = "web_a_pub"
  zone = "ru-central1-a"
  network_id = yandex_vpc_network.web_network.id
  v4_cidr_blocks = ["192.168.4.0/24"]

}

resource "yandex_vpc_subnet" "web_SN_b" {
  name = "web_b"
  zone = "ru-central1-b"
  network_id = yandex_vpc_network.web_network.id
  v4_cidr_blocks = ["192.168.2.0/24"]
}

resource "yandex_compute_instance" "web_bastion" {
  name = "web-bastion"
  platform_id = "standard-v1"
  zone = "ru-central1-b"
  allow_stopping_for_update = true

  resources {
    cores = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
        image_id = "fd8qfp90a5l0m3d2htrm"
    }
  }

  metadata = {
  user-data = "${file("meta.yml")}"
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.web_bastionSN_b.id}"
    nat = true
    nat_ip_address = yandex_vpc_address.external_address_bastion.external_ipv4_address[0].address
    security_group_ids = [yandex_vpc_security_group.sg_bastion.id]
    }
}

resource "yandex_compute_instance" "web1" {
  name = "web1"
  platform_id = "standard-v1"
  zone = "ru-central1-a"
  allow_stopping_for_update = true

  resources {
    cores = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
        image_id = "fd87kbts7j40q5b9rpjr"
    }
  }

  metadata = {
  user-data = "${file("meta.yml")}"
  }

  network_interface {
    index = 1
    subnet_id = "${yandex_vpc_subnet.web_SN.id}"
  }  
}

resource "yandex_compute_instance" "web2" {
  name = "web2"
  platform_id = "standard-v1"
  zone = "ru-central1-b"
  allow_stopping_for_update = true

  resources {
    cores = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
        image_id = "fd87kbts7j40q5b9rpjr"
    }
  }

  metadata = {
  user-data = "${file("meta.yml")}"
  }

  network_interface {
    index = 1
    subnet_id = "${yandex_vpc_subnet.web_SN_b.id}"
  }  
}

resource "yandex_compute_instance" "web_prometheus" {
  name = "web-prometheus"
  platform_id = "standard-v1"
  zone = "ru-central1-a"
  allow_stopping_for_update = true

  resources {
    cores = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
        image_id = "fd87kbts7j40q5b9rpjr"
    }
  }

  metadata = {
  user-data = "${file("meta.yml")}"
  }

  network_interface {
    index = 1
    subnet_id = "${yandex_vpc_subnet.web_SN.id}"
  }  
}

resource "yandex_compute_instance" "web_elastic" {
  name = "web-elastic"
  platform_id = "standard-v1"
  zone = "ru-central1-a"
  allow_stopping_for_update = true

  resources {
    cores = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
        image_id = "fd87kbts7j40q5b9rpjr"
    }
  }

  metadata = {
  user-data = "${file("meta.yml")}"
  }

  network_interface {
    index = 1
    subnet_id = "${yandex_vpc_subnet.web_SN.id}"
  }  
}

resource "yandex_compute_instance" "web_grafana" {
  name = "web-grafana"
  platform_id = "standard-v1"
  zone = "ru-central1-a"
  allow_stopping_for_update = true

  resources {
    cores = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
        image_id = "fd87kbts7j40q5b9rpjr"
    }
  }

  metadata = {
  user-data = "${file("meta.yml")}"
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.web_pub_SN.id}"
    nat = true
    nat_ip_address = yandex_vpc_address.external_address.external_ipv4_address[0].address
    security_group_ids = [yandex_vpc_security_group.sg_grafana.id, yandex_vpc_default_security_group.sg_web_and_node_explorer.id]
    }
}

resource "yandex_compute_instance" "web_kibana" {
  name = "web-kibana"
  platform_id = "standard-v1"
  zone = "ru-central1-a"
  allow_stopping_for_update = true

  resources {
    cores = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
        image_id = "fd87kbts7j40q5b9rpjr"
    }
  }

  metadata = {
  user-data = "${file("meta.yml")}"
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.web_pub_SN.id}"
    nat = true
    nat_ip_address = yandex_vpc_address.external_address_kibana.external_ipv4_address[0].address
    security_group_ids = [yandex_vpc_security_group.sg_kibana.id, yandex_vpc_default_security_group.sg_web_and_node_explorer.id]
    }
}

resource "yandex_alb_target_group" "web_tg" {
    name = "web-tg"

    target {
        subnet_id = "${yandex_vpc_subnet.web_SN.id}"
        ip_address = "${yandex_compute_instance.web1.network_interface.0.ip_address}"
    }

    target {
        subnet_id = "${yandex_vpc_subnet.web_SN_b.id}"
        ip_address = "${yandex_compute_instance.web2.network_interface.0.ip_address}"
    }
  
}

resource "yandex_alb_backend_group" "web_bg" {
    name = "web-backend-group"

    http_backend {
        name = "web-http-backend"
        weight = 1
        port = 80
        target_group_ids = ["${yandex_alb_target_group.web_tg.id}"]
        healthcheck {
          timeout = "1s"
          interval = "10s"
          healthcheck_port = 80
          http_healthcheck {
            path  = "/"
          }
        }
        http2 = "false"
    }
}

resource "yandex_alb_http_router" "http-router" {
    name = "http-router"
}

resource "yandex_alb_virtual_host" "http-router-host" {
    name = "router-host"
    http_router_id = yandex_alb_http_router.http-router.id
    route {
        name = "to-webs"
        http_route {
            http_route_action {
                backend_group_id = yandex_alb_backend_group.web_bg.id
                timeout = "60s"
            }
        }
    }
}

resource "yandex_alb_load_balancer" "web-balancer" {
    name = "http-web-balancer"

    network_id = yandex_vpc_network.web_network.id
    security_group_ids = [yandex_vpc_security_group.balancer.id, yandex_vpc_default_security_group.sg_web_and_node_explorer.id]

    allocation_policy {
        location {
            zone_id = "ru-central1-a"
            subnet_id = yandex_vpc_subnet.web_SN.id
        }
        location {
            zone_id = "ru-central1-b"
            subnet_id = yandex_vpc_subnet.web_SN_b.id
        }
    }

    listener {
        name = "weblistner"
        endpoint {
            address {
                external_ipv4_address {
                }
            }
            ports = [80]
        }
        http {
            handler {
                http_router_id = yandex_alb_http_router.http-router.id
            }
        }
    }
}

resource "yandex_vpc_security_group" "sg_grafana" {
    network_id = yandex_vpc_network.web_network.id
    name = "sg_grafana"
    description =  "Allow 3000"

    ingress {
        description = "Allow 3000"
        protocol = "TCP"
        port = "3000"
        v4_cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        description = "Allow all"
        protocol = "ANY"
        v4_cidr_blocks = ["0.0.0.0/0"]
    }

        ingress {
        description = "Allow ping"
        protocol = "ICMP"
        v4_cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        description = "Allow ping"
        protocol = "ICMP"
        v4_cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "yandex_vpc_security_group" "sg_kibana" {
    network_id = yandex_vpc_network.web_network.id
    name = "sg_kibana"
    description =  "Allow 5601"

    ingress {
        description = "Allow 5601"
        protocol = "TCP"
        port = "5601"
        v4_cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        description = "Allow any"
        protocol = "ANY"
        v4_cidr_blocks = ["0.0.0.0/0"]
    }

        ingress {
        description = "Allow ping"
        protocol = "ICMP"
        v4_cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        description = "Allow ping"
        protocol = "ICMP"
        v4_cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "yandex_vpc_security_group" "balancer" {  
  name = "balancer_public"
  description =  "Разрешение на подключение к alb из сети Инертнет по HHTP (80)" 
  network_id = yandex_vpc_network.web_network.id 
  ingress {
    protocol = "ANY" 
    description = "Health checks"
    v4_cidr_blocks = ["0.0.0.0/0"]
    predefined_target = "loadbalancer_healthchecks"
  }
  ingress {
    protocol = "TCP" 
    description = "allow HTTP connections from internet" 
    v4_cidr_blocks = ["0.0.0.0/0"]
    port = 80
  }
  ingress {
    protocol = "ICMP" 
    description = "allow ping" 
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol = "ANY" 
    description = "allow any outgoing connection" 
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_default_security_group" "sg_web_and_node_explorer" {
    network_id = yandex_vpc_network.web_network.id
    description =  "Allow all inside"

    ingress {
        description = "Allow all inside"
        protocol = "ANY"
        v4_cidr_blocks = ["192.168.0.0/16"]
    }

    egress {
        description = "Allow all inside"
        protocol = "ANY"
        v4_cidr_blocks = ["192.168.0.0/16"]
    }
}

resource "yandex_vpc_security_group" "sg_bastion" {
    network_id = yandex_vpc_network.web_network.id
    ingress {
        description = "Allow only ssh"
        protocol = "TCP"
        port = "22"
        v4_cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        description = "Allow only ssh"
        protocol = "ANY"
        v4_cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "Allow ping"
        protocol = "ICMP"
        v4_cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        description = "Allow ping"
        protocol = "ICMP"
        v4_cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "yandex_vpc_route_table" "bastion-rt" {
  name = "route-table-for-bastion"
  network_id = yandex_vpc_network.web_network.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address = yandex_compute_instance.web_bastion.network_interface.0.ip_address
  }
}

resource "yandex_vpc_address" "external_address" {
  name = "external-IP"
  external_ipv4_address {
    zone_id = "ru-central1-a"
  }
}

resource "yandex_vpc_address" "external_address_kibana" {
  name = "external-IP-kibana"
  external_ipv4_address {
    zone_id = "ru-central1-a"
  }
}

resource "yandex_vpc_address" "external_address_bastion" {
  name = "external-IP-bastion"
  external_ipv4_address {
    zone_id = "ru-central1-b"
  }
}

output "web1_ip_address" {
  value = yandex_compute_instance.web1.network_interface.0.ip_address
}

output "web2_ip_address" {
  value = yandex_compute_instance.web2.network_interface.0.ip_address
}

output "web_prometheus_ip_address" {
  value = yandex_compute_instance.web_prometheus.network_interface.0.ip_address
}

output "web_elastic_ip_address" {
  value = yandex_compute_instance.web_elastic.network_interface.0.ip_address
}

output "web_bastion_nat_ip_address" {
  value = yandex_compute_instance.web_bastion.network_interface.0.nat_ip_address
}

output "web_grafana_ip_address" {
  value = yandex_compute_instance.web_grafana.network_interface.0.ip_address
}

output "web_grafana_nat_ip_address" {
  value = yandex_compute_instance.web_grafana.network_interface.0.nat_ip_address
}

output "web_kibana_ip_address" {
  value = yandex_compute_instance.web_kibana.network_interface.0.ip_address
}

output "web_kibana_nat_ip_address" {
  value = yandex_compute_instance.web_kibana.network_interface.0.nat_ip_address
}

resource "yandex_compute_snapshot_schedule" "snapshot" {
  name = "snapshot"
  schedule_policy {
    expression = "0 0 ? * *"
  }
  snapshot_count = 7
  snapshot_spec {
    description = "daily-snapshot"
  }
  disk_ids = [yandex_compute_instance.web_bastion.boot_disk.0.disk_id, yandex_compute_instance.web1.boot_disk.0.disk_id, yandex_compute_instance.web2.boot_disk.0.disk_id, yandex_compute_instance.web_prometheus.boot_disk.0.disk_id, yandex_compute_instance.web_elastic.boot_disk.0.disk_id, yandex_compute_instance.web_grafana.boot_disk.0.disk_id, yandex_compute_instance.web_kibana.boot_disk.0.disk_id]
}