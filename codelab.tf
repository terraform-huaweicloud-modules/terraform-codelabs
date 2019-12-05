resource "random_id" "this" {
  byte_length = 4
}

data "huaweicloud_images_image_v2" "this" {
  most_recent = true
  visibility = "public"
  name = "CentOS 6.5 64bit"
}

resource "huaweicloud_vpc_v1" "this" {
  name = "vpc_${random_id.this.hex}"
  cidr = "192.168.0.0/16"
}

resource "huaweicloud_vpc_subnet_v1" "this" {
  name = "subnet_${random_id.this.hex}"
  cidr = "192.168.0.0/16"
  gateway_ip = "192.168.0.1"
  vpc_id = "${huaweicloud_vpc_v1.this.id}"
  availability_zone = "cn-north-1a"
}

resource "huaweicloud_compute_instance_v2" "this" {
  name = "instance_${random_id.this.hex}"
  security_groups = ["default"]
  availability_zone = "cn-north-1a"
  image_id = "${data.huaweicloud_images_image_v2.this.id}"
  flavor_name = "s2.small.1"
  metadata = {
    foo = "bar"
  }
  network {
    uuid = "${huaweicloud_vpc_subnet_v1.this.id}"
  }
}

resource "huaweicloud_vpc_eip_v1" "this" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name = "bd_${random_id.this.hex}"
    size = 8
    share_type = "PER"
    charge_mode = "traffic"
  }
}

resource "huaweicloud_compute_floatingip_associate_v2" "this" {
  floating_ip = "${huaweicloud_vpc_eip_v1.this.publicip.0.ip_address}"
  instance_id = "${huaweicloud_compute_instance_v2.this.id}"
}

output "ip" {
  value = "${huaweicloud_vpc_eip_v1.this.publicip.0.ip_address}"
}
