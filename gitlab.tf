provider "google" {
    credentials = "${file("gce_key.json")}"
    project = "${var.project}"
    region = "${var.region}"
}

resource "google_compute_firewall" "external_ports_no_ssh" {
    name = "gitlab-external-ports"
    network = "default"

    allow {
        protocol = "tcp"
        ports = "${var.public_ports_no_ssl}"
    }
}

resource "random_id" "runner_token" {
    byte_length = 15
}

data "template_file" "gitlab" {
    template = "${file("${path.module}/templates/gitlab.rb.append")}"

    vars = {
        runner_token = "${var.runner_token != "GENERATE" ? var.runner_token : format("%s", random_id.runner_token.hex)}"
    }
}

resource "google_compute_instance" "gitlab-ce" {
    name = "${var.instance_name}"
    machine_type = "${var.machine_type}"
    zone = "${var.zone}"

    tags = ["gitlab"]

    connection {
        host = "${self.network_interface.0.access_config.0.nat_ip}"
        type = "ssh"
        user = "jerrye"
        agent = "false"
        private_key = "${file("${var.ssh_key}")}"
    }

    boot_disk {
        initialize_params {
            image = "${var.image}"
            size = "${var.image_size}"
        }
        auto_delete = "false"
    }

    network_interface {
        network = "default"
        access_config {}
    }

    metadata = {
        ssh-keys = "jerrye:${file("${var.ssh_key}.pub")}"
    }

    provisioner "file" {
        content = "${data.template_file.gitlab.rendered}"
        destination = "/tmp/gitlab.rb.append"
    }

    provisioner "file" {
        source = "${path.module}/gitlab.rb"
        destination = "/tmp/gitlab.rb"
    }

    provisioner "file" {
        source = "${path.module}/bootstrap"
        destination = "/tmp/bootstrap"
    }

    provisioner "remote-exec" {
        inline = [
            "cat /tmp/gitlab.rb.append >> /tmp/gitlab.rb",
            "chmod +x /tmp/bootstrap",
            "sudo /tmp/bootstrap ${var.dns_name}"
        ]
    }
}

resource "google_dns_managed_zone" "gitlab-zone" {
    name = "gitlab-zone"
    dns_name = "${var.dns_zone}"
}

resource "google_dns_record_set" "server" {
    name = "${var.dns_name}"
    type = "A"
    ttl = 300
    managed_zone = "${google_dns_managed_zone.gitlab-zone.name}"
    rrdatas = ["${google_compute_instance.gitlab-ce.network_interface.0.access_config.0.nat_ip}"]
}