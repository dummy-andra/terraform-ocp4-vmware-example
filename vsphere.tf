provider "vsphere" {
  version        = "~> 1.1"
  vsphere_server = "${var.vsphere_server}"

  # if you have a self-signed cert
  allow_unverified_ssl = "${var.vsphere_allow_unverified_ssl}"
}

##################################
#### Collect resource IDs
##################################
data "vsphere_datacenter" "dc" {
  name = "${var.vsphere_datacenter}"
}

data "vsphere_compute_cluster" "cluster" {
  name          = "${var.vsphere_cluster}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_datastore" "datastore" {
  count = "${var.datastore != "" ? 1 : 0}"

  name          = "${var.datastore}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_datastore_cluster" "datastore_cluster" {
  count = "${var.datastore_cluster != "" ? 1 : 0}"

  name          = "${var.datastore_cluster}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_resource_pool" "pool" {
  name          = "${var.vsphere_cluster}/Resources/${var.vsphere_resource_pool}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "private_network" {
  name          = "${var.private_network_label}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "public_network" {
  count         = "${var.public_network_label != "" ? 1 : 0}"
  name          = "${var.public_network_label}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

# Create a folder
resource "vsphere_folder" "ocpenv" {
  count         = "${var.folder != "" ? 1 : 0}"
  path          = "${var.folder}"
  type          = "vm"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

locals {
  folder_path = "${var.folder != "" ?
    element(concat(vsphere_folder.ocpenv.*.path, list("")), 0)
  : ""}"
}