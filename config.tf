variable "project" {
    description = "The project in Google Cloud to create the Gitlab instance under"
    default = "gitlab-258109"
}

variable "region" {
    description = "The region this all lives in"
    default = "us-east1"
}

variable "zone" {
    description = "The zone to deploy the machine to"
    default = "us-east1-b"
}

variable "public_ports_no_ssl" {
    description = "A list of ports that need to be opened for Gitlab to work"
    default = ["80", "22"]
}

variable "instance_name" {
    description = "The name of the instance to use"
    default = "gitlab-instance"
}

variable "machine_type" {
    description = "A machine type for your compute instance"
    default = "n1-standard-1"
}

variable "image" {
    description = "The image to use for the instance"
    default = "ubuntu-os-cloud/ubuntu-1804-lts"
}

variable "image_size" {
    default = 20
}

variable "ssh_key" {
    description = "The ssh key to use to connect to the Google Cloud Instance"
    default = "~/.ssh/gitlab"
}

variable "dns_zone" {
    description = "The name of the DNS zone in Google Cloud"
    default = "gitlab.vodomat.net."
}

variable "dns_name" {
    description = "The DNS name of the Gitlab instance"
    default = "server.gitlab.vodomat.net."
}

variable "runner_instance_name" {
    default = "runner-instance"
}

variable "runner_machine_type" {
    default = "f1-micro"
}

variable "runner_disk_size" {
    default = 10
}

variable "runner_image" {
    description = "The docker image a Gitlab CI Runner will use by default"
    default = "ruby:2.3"
}

variable "runner_token" {
    description = "Gitlab CI Runner registration token. Will be generated if not provided"
    default = "GENERATE"
}