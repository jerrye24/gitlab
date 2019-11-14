resource "google_compute_instance" "gitlab-ci-runner" {
    name = "${var.runner_instance_name}"
    machine_type = "${var.runner_machine_type}"
    zone = "${var.zone}"

    tags = ["gitlab-ci-runner"]

    network_interface {
        network = "default"
        access_config {}
    }

    metadata = {
        ssh-keys = "jerrye:${file("${var.ssh_key}.pub")}"
    }

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
            size = "${var.runner_disk_size}"
        }
    }

    provisioner "file" {
        source = "${path.module}/bootstrap_runner"
        destination = "/tmp/bootstrap_runner"
    }

    provisioner "remote-exec" {
        inline = [
            "chmod +x /tmp/bootstrap_runner",
            "sudo /tmp/bootstrap_runner ${google_compute_instance.gitlab-ci-runner.name} http://${var.dns_name} ${data.template_file.gitlab.vars.runner_token} ${var.runner_image}"
        ]
    }

    provisioner "remote-exec" {
        when = "destroy"
        inline = [
            "sudo gitlab-ci-multi-runner unregister --name ${google_compute_instance.gitlab-ci-runner.name}"
        ]
    }
}