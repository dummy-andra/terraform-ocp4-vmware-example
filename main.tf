###########################################################
### Generate Random Tag
###########################################################

resource "random_id" "tag" {
  byte_length = 4
}

###########################################################
### Generate SSH Key
###########################################################

resource "tls_private_key" "installkey" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "local_file" "write_private_key" {
  content  = "${tls_private_key.installkey.private_key_pem}"
  filename = "${path.module}/artifacts/openshift_rsa"
}

resource "local_file" "write_public_key" {
  content  = "${tls_private_key.installkey.public_key_openssh}"
  filename = "${path.module}/artifacts/openshift_rsa.pub"
}

###########################################################
### Deploy Supporting Infrastructure
###########################################################

locals {
  empty_list = [""]
}

module "support_infrastructure" {
  source = "github.com/ncolon/terraform-ocp4-supportinfra-vmware?ref=v1.0"

  # vsphere information
  vsphere_server           = "${var.vsphere_server}"
  vsphere_cluster_id       = "${data.vsphere_compute_cluster.cluster.id}"
  vsphere_datacenter_id    = "${data.vsphere_datacenter.dc.id}"
  vsphere_resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  private_network_id       = "${data.vsphere_network.private_network.id}"
  public_network_id        = "${var.public_network_label != "" ? data.vsphere_network.public_network.0.id : ""}"
  datastore_id             = "${var.datastore != "" ? data.vsphere_datastore.datastore.0.id : ""}"
  datastore_cluster_id     = "${var.datastore_cluster != "" ? data.vsphere_datastore_cluster.datastore_cluster.0.id : ""}"
  folder_path              = "${local.folder_path}"

  instance_name = "${var.hostname_prefix}-${random_id.tag.hex}"

  public_gateway     = "${var.public_gateway}"
  public_netmask     = "${var.public_netmask}"
  public_domain      = "${var.public_domain}"
  public_dns_servers = "${var.public_dns_servers}"

  cluster_name       = "${var.cluster_name}"
  dns_private_ip     = "${var.dns_private_ip}"
  dns_public_ip      = "${var.dns_public_ip}"
  bastion_private_ip = "${var.bastion_private_ip}"
  bastion_public_ip  = "${var.bastion_public_ip}"


  private_netmask     = "${var.private_netmask}"
  private_gateway     = "${var.private_gateway}"
  private_domain      = "${var.private_domain}"
  private_dns_servers = "${var.dns_private_ip}"

  # how to ssh into the template
  rhel_template            = "${var.rhel_template}"
  template_ssh_user        = "${var.ssh_user}"
  template_ssh_password    = "${var.ssh_password}"
  template_ssh_private_key = "${file(var.ssh_private_key_file)}"

  # the keys to be added between bastion host and the VMs
  ssh_user        = "${var.ssh_user}"
  ssh_private_key = "${tls_private_key.installkey.private_key_pem}"
  ssh_public_key  = "${tls_private_key.installkey.public_key_openssh}"

  # information about VM types
  bastion = "${var.bastion}"
  dns     = "${var.dns}"
}

module "external_lb" {
  source = "github.com/ncolon/terraform-ocp4-lb-haproxy-vmware?ref=v1.0"

  vsphere_server               = "${var.vsphere_server}"
  vsphere_allow_unverified_ssl = "${var.vsphere_allow_unverified_ssl}"

  vsphere_datacenter_id    = "${data.vsphere_datacenter.dc.id}"
  vsphere_cluster_id       = "${data.vsphere_compute_cluster.cluster.id}"
  vsphere_resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id             = "${var.datastore != "" ? data.vsphere_datastore.datastore.0.id : ""}"
  datastore_cluster_id     = "${var.datastore_cluster != "" ? data.vsphere_datastore_cluster.datastore_cluster.0.id : ""}"

  # Folder to provision the new VMs in, does not need to exist in vSphere
  folder_path   = "${local.folder_path}"
  instance_name = "${var.hostname_prefix}-${random_id.tag.hex}-console"

  private_network_id = "${data.vsphere_network.private_network.id}"
  private_ip_address = "${var.externallb_private_ip}"
  private_netmask    = "${var.private_netmask}"
  private_gateway    = "${var.private_gateway}"
  private_domain     = "${var.private_domain}"

  public_network_id = "${var.public_network_label != "" ? data.vsphere_network.public_network.0.id : ""}"
  public_ip_address = "${var.public_network_label != "" ? var.externallb_public_ip : local.empty_list}"
  public_netmask    = "${var.public_network_label != "" ? var.public_netmask : ""}"
  public_gateway    = "${var.public_network_label != "" ? var.public_gateway : ""}"
  public_domain     = "${var.public_domain}"

  dns_servers = "${compact(concat(var.public_dns_servers, var.dns_private_ip))}"

  # how to ssh into the template
  template                 = "${var.rhel_template}"
  template_ssh_user        = "${var.ssh_user}"
  template_ssh_password    = "${var.ssh_password}"
  template_ssh_private_key = "${file(var.ssh_private_key_file)}"

  rhn_username = "${var.rhn_username}"
  rhn_password = "${var.rhn_password}"
  rhn_poolid   = "${var.rhn_poolid}"

  bastion_ip_address = "${module.support_infrastructure.bastion_public_ip}"

  frontend = ["80", "443", "6443"]
  backend = {
    "6443" = "${join(",", compact(concat(var.control_plane_private_ip, list(var.bootstrap_complete ? "" : element(var.bootstrap_ip_address, 0)))))}",
    "443"  = "${join(",", var.worker_ip_address)}"
    "80"   = "${join(",", var.worker_ip_address)}"
  }
}

module "internal_lb" {
  source = "github.com/ncolon/terraform-ocp4-lb-haproxy-vmware?ref=v1.0"

  vsphere_server               = "${var.vsphere_server}"
  vsphere_allow_unverified_ssl = "${var.vsphere_allow_unverified_ssl}"

  vsphere_datacenter_id    = "${data.vsphere_datacenter.dc.id}"
  vsphere_cluster_id       = "${data.vsphere_compute_cluster.cluster.id}"
  vsphere_resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id             = "${var.datastore != "" ? data.vsphere_datastore.datastore.0.id : ""}"
  datastore_cluster_id     = "${var.datastore_cluster != "" ? data.vsphere_datastore_cluster.datastore_cluster.0.id : ""}"

  # Folder to provision the new VMs in, does not need to exist in vSphere
  folder_path   = "${local.folder_path}"
  instance_name = "${var.hostname_prefix}-${random_id.tag.hex}-app"

  private_network_id = "${data.vsphere_network.private_network.id}"
  private_ip_address = "${var.internallb_private_ip}"
  private_netmask    = "${var.private_netmask}"
  private_gateway    = "${var.private_gateway}"
  private_domain     = "${var.private_domain}"

  public_network_id = "${var.public_network_label != "" ? data.vsphere_network.public_network.0.id : ""}"
  public_ip_address = "${var.public_network_label != "" ? var.internallb_public_ip : local.empty_list}"
  public_netmask    = "${var.public_network_label != "" ? var.public_netmask : ""}"
  public_gateway    = "${var.public_network_label != "" ? var.public_gateway : ""}"
  public_domain     = "${var.public_domain}"

  dns_servers = "${compact(concat(var.public_dns_servers, var.dns_private_ip))}"

  # how to ssh into the template
  template                 = "${var.rhel_template}"
  template_ssh_user        = "${var.ssh_user}"
  template_ssh_password    = "${var.ssh_password}"
  template_ssh_private_key = "${file(var.ssh_private_key_file)}"

  bastion_ip_address = "${module.support_infrastructure.bastion_public_ip}"

  rhn_username = "${var.rhn_username}"
  rhn_password = "${var.rhn_password}"
  rhn_poolid   = "${var.rhn_poolid}"

  frontend = ["80", "443", "6443", "22623"]
  backend = {
    "6443"  = "${join(",", compact(concat(var.control_plane_private_ip, list(var.bootstrap_complete ? "" : element(var.bootstrap_ip_address, 0)))))}",
    "22623" = "${join(",", compact(concat(var.control_plane_private_ip, list(var.bootstrap_complete ? "" : element(var.bootstrap_ip_address, 0)))))}"
    "443"   = "${join(",", var.worker_ip_address)}"
    "80"    = "${join(",", var.worker_ip_address)}"
  }
}

locals {
  rhn_all_nodes = "${concat(
    "${list(module.support_infrastructure.bastion_public_ip)}",
    "${module.support_infrastructure.dns_private_ip}",
  )}"

  rhn_all_count = "${var.bastion["nodes"] + var.dns["nodes"]}"
}


module "rhnregister" {
  source = "github.com/ibm-cloud-architecture/terraform-openshift-rhnregister"

  dependson = [
    "${module.support_infrastructure.module_completed}"
  ]

  bastion_ip_address      = "${module.support_infrastructure.bastion_public_ip}"
  bastion_ssh_user        = "${var.ssh_user}"
  bastion_ssh_password    = "${var.ssh_password}"
  bastion_ssh_private_key = "${file(var.ssh_private_key_file)}"

  ssh_user        = "${var.ssh_user}"
  ssh_private_key = "${tls_private_key.installkey.private_key_pem}"

  rhn_username = "${var.rhn_username}"
  rhn_password = "${var.rhn_password}"
  rhn_poolid   = "${var.rhn_poolid}"
  all_nodes    = "${local.rhn_all_nodes}"
  all_count    = "${local.rhn_all_count}"
}

module "dnsregister" {
  source = "github.com/ncolon/terraform-ocp4-dnsregister?ref=v1.0"

  dependson = [
    "${module.support_infrastructure.module_completed}",
    "${module.rhnregister.registered_resource}",
  ]

  bastion_ip_address = "${module.support_infrastructure.bastion_public_ip}"

  ssh_user        = "${var.ssh_user}"
  ssh_password    = "${var.ssh_password}"
  ssh_private_key = "${tls_private_key.installkey.private_key_pem}"

  dns_private_ip = "${module.support_infrastructure.dns_private_ip}"
  dns_public_ip  = "${module.support_infrastructure.dns_public_ip}"

  private_domain     = "${var.private_domain}"
  dns_key_name_internal = "${var.dns_key_name_internal}"
  dns_key_name_external = "${var.dns_key_name_external}"
  dns_key_algorithm  = "${var.dns_key_algorithm}"
  dns_key_secret_internal = "${var.dns_key_secret_internal}"
  dns_key_secret_external = "${var.dns_key_secret_external}"
  dns_record_ttl     = "${var.dns_record_ttl}"
  public_dns_servers = "${var.public_dns_servers}"

  cluster_name             = "${var.cluster_name}"
  control_plane            = "${var.control_plane}"
  worker                   = "${var.worker}"
  worker_ip_address        = "${var.worker_ip_address}"
  control_plane_private_ip = "${var.control_plane_private_ip}"
  bootstrap_ip_address     = "${var.bootstrap_ip_address}"

  applb_private_ip     = "${module.external_lb.node_private_ip}"
  controllb_private_ip = "${module.internal_lb.node_private_ip}"
  applb_public_ip      = "${module.external_lb.node_public_ip}"
  controllb_public_ip  = "${module.internal_lb.node_public_ip}"

}

module "openshift" {
  source = "github.com/ncolon/terraform-ocp4-deploy-vmware?ref=v1.0"

  dependson = [
    "${module.support_infrastructure.module_completed}",
    "${module.rhnregister.registered_resource}",
    "${module.dnsregister.module_completed}",
  ]

  # vsphere information
  vsphere_server           = "${var.vsphere_server}"
  vsphere_cluster_id       = "${data.vsphere_compute_cluster.cluster.id}"
  vsphere_datacenter_id    = "${data.vsphere_datacenter.dc.id}"
  vsphere_resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  private_network_id       = "${data.vsphere_network.private_network.id}"
  public_network_id        = "${var.public_network_label != "" ? data.vsphere_network.public_network.0.id : ""}"
  datastore_id             = "${var.datastore != "" ? data.vsphere_datastore.datastore.0.id : ""}"
  datastore_cluster_id     = "${var.datastore_cluster != "" ? data.vsphere_datastore_cluster.datastore_cluster.0.id : ""}"
  folder_path              = "${local.folder_path}"

  instance_name = "${var.hostname_prefix}-${random_id.tag.hex}"

  public_gateway     = "${var.public_gateway}"
  public_netmask     = "${var.public_netmask}"
  public_domain      = "${var.public_domain}"
  public_dns_servers = "${var.public_dns_servers}"

  cluster_name             = "${var.cluster_name}"
  dns_private_ip           = "${var.dns_private_ip}"
  control_plane_private_ip = "${var.control_plane_private_ip}"
  worker_ip_address        = "${var.worker_ip_address}"
  bootstrap_ip_address     = "${var.bootstrap_ip_address}"
  bastion_private_ip       = "${var.bastion_private_ip}"
  bastion_public_ip        = "${var.bastion_public_ip}"


  private_netmask              = "${var.private_netmask}"
  private_gateway              = "${var.private_gateway}"
  private_domain               = "${var.private_domain}"
  private_dns_servers          = "${var.private_dns_servers}"

  # how to ssh into the template
  rhel_template            = "${var.rhel_template}"
  rhcos_template           = "${var.rhcos_template}"
  template_ssh_user        = "${var.ssh_user}"
  template_ssh_password    = "${var.ssh_password}"
  template_ssh_private_key = "${file(var.ssh_private_key_file)}"

  # the keys to be added between bastion host and the VMs
  ssh_user        = "${var.ssh_user}"
  ssh_private_key = "${tls_private_key.installkey.private_key_pem}"
  ssh_public_key  = "${tls_private_key.installkey.public_key_openssh}"

  # information about VM types
  worker = "${var.worker}"
  additional_disk = "${var.additional_disk}"

  openshift_pull_secret = "${var.openshift_pull_secret}"
  control_plane_count   = "${var.control_plane["count"]}"
  service_network_cidr  = "${var.service_network_cidr}"
  cluster_network_cidr  = "${var.cluster_network_cidr}"
  host_prefix           = "${var.host_prefix}"
}
