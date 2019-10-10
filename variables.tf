####################################
# vCenter Configuration
####################################
variable "vsphere_server" {}
variable "vsphere_allow_unverified_ssl" {
  default = true
}

variable "vsphere_datacenter" {}
variable "vsphere_cluster" {}
variable "vsphere_resource_pool" {}
variable "datastore" {
  default = ""
}
variable "datastore_cluster" {
  default = ""
}
variable "rhel_template" {}
variable "rhcos_template" {}
variable "folder" {}

####################################
# Infrastructure Configuration
####################################

variable "hostname_prefix" {
  default = ""
}

variable "ssh_user" {}
variable "ssh_password" {}

variable "ssh_private_key_file" {
  default = "~/.ssh/id_rsa"
}

variable "ssh_public_key_file" {
  default = "~/.ssh/id_rsa.pub"
}

variable "bastion_ssh_private_key_file" {
  default = "~/.ssh/id_rsa"
}

variable "private_network_label" {}
variable "private_domain" {}
variable "private_netmask" {}
variable "private_gateway" {}
variable "private_dns_servers" {
  type    = "list"
  default = []
}

variable "public_network_label" {
  default = ""
}

variable "public_netmask" {
  default = "0"
}

variable "public_gateway" {
  default = ""
}

variable "public_domain" {
  default = ""
}

variable "public_dns_servers" {
  type    = "list"
  default = []
}

variable "bastion" {
  type = "map"

  default = {
    nodes               = "1"
    vcpu                = "2"
    memory              = "8192"
    disk_size           = ""      # Specify size or leave empty to use same size as template.
    docker_disk_size    = "100"   # Specify size for docker disk, default 100.
    thin_provisioned    = ""      # True or false. Whether to use thin provisioning on the disk. Leave blank to use same as template
    eagerly_scrub       = ""      # True or false. If set to true disk space is zeroed out on VM creation. Leave blank to use same as template
    keep_disk_on_remove = "false" # Set to 'true' to not delete a disk on removal.
  }
}

variable "bastion_ip_address" {
  type    = "list"
  default = []
}

variable "bastion_private_ip_address" {
  type    = "list"
  default = []
}

variable "dns" {
  type = "map"

  default = {
    nodes               = "1"
    vcpu                = "2"
    memory              = "4096"
    disk_size           = ""      # Specify size or leave empty to use same size as template.
    thin_provisioned    = ""      # True or false. Whether to use thin provisioning on the disk. Leave blank to use same as template
    eagerly_scrub       = ""      # True or false. If set to true disk space is zeroed out on VM creation. Leave blank to use same as template
    keep_disk_on_remove = "false" # Set to 'true' to not delete a disk on removal.
  }
}

variable "control_plane" {
  type = "map"

  default = {
    count  = "3"
    vcpu   = "8"
    memory = "16384"
  }
}

variable "worker" {
  type = "map"

  default = {
    count  = "3"
    vcpu   = "8"
    memory = "16384"
  }
}

variable "additional_disk" {
  type = "map"

  default = {
    disk_size           = "500"   # Specify size or leave empty to use same size as template.
    thin_provisioned    = "true"  # True or false. Whether to use thin provisioning on the disk. Leave blank to use same as template
    eagerly_scrub       = "false" # True or false. If set to true disk space is zeroed out on VM creation. Leave blank to use same as template
    keep_disk_on_remove = "false" # Set to 'true' to not delete a disk on removal.
  }
}

variable "dns_private_ip" {
  type    = "list"
  default = []
}

variable "dns_public_ip" {
  type    = "list"
  default = []
}

variable "bastion_public_ip" {
  type    = "list"
  default = []
}

variable "bastion_private_ip" {
  type    = "list"
  default = []
}
variable "control_plane_private_ip" {
  type    = "list"
  default = []
}

variable "worker_ip_address" {
  type    = "list"
  default = []
}

variable "bootstrap_ip_address" {
  type    = "list"
  default = []
}


####################################
# RHN Registration
####################################
variable "rhn_username" {}
variable "rhn_password" {}
variable "rhn_poolid" {}



####################################
# OpenShift Installation
####################################
variable "cluster_network_cidr" {
  default = "10.128.0.0/14"
}

variable "service_network_cidr" {
  default = "172.30.0.0/16"
}

variable "openshift_pull_secret" {
  default = "pull-secret.txt"
}

variable "host_prefix" {
  default = "24"
}

variable "cluster_name" {
  default = "ncolon-ocp4"
}


variable "dns_key_name_internal" {}
variable "dns_key_name_external" {}
variable "dns_key_algorithm" {}
variable "dns_key_secret_internal" {}
variable "dns_key_secret_external" {}
variable "dns_record_ttl" {
  default = 300
}

variable "bootstrap_complete" {
  default = false
}


variable "internallb_public_ip" {
  type    = "list"
  default = []
}

variable "internallb_private_ip" {
  default = []
}

variable "externallb_public_ip" {
  type    = "list"
  default = []
}

variable "externallb_private_ip" {
  default = []
}


