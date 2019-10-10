#######################################
##### vSphere Access Credentials ######
#######################################
vsphere_server = "vcsa67.rtp.raleigh.ibm.com"

# Set username/password as environment variables VSPHERE_USER and VSPHERE_PASSWORD
ssh_user                     = "<SSH_USER>"
ssh_password                 = "<SSH_PASSWORD>"
ssh_private_key_file         = "~/.ssh/openshift_rsa"
ssh_public_key_file          = "~/.ssh/openshift_rsa.pub"
bastion_ssh_private_key_file = "~/.ssh/openshift_rsa"
##############################################
##### vSphere deployment specifications ######
##############################################
# Following resources must exist in vSphere
vsphere_datacenter    = "dc01"
vsphere_cluster       = "cluster01"
vsphere_resource_pool = "ncolon"
datastore_cluster     = "dc01-ocp-cluster"
rhel_template         = "rhel-7.6-template-32gb"
rhcos_template        = "rhcos-41"

# Folder to provision the new VMs in, does not need to exist in vSphere
folder = "ncolon-ocp4"

# MUST consist of only lower case alphanumeric characters and '-'
hostname_prefix = "ncolon-ocp4"
cluster_name    = "ncolon-ocp4"

rhn_username = "<RHN_USERNAME>"
rhn_password = "<RHN_PASSWORD>"
rhn_poolid   = "<RHN_POOLID>"

##### Network #####
private_network_label = "vdpg-192.168.100"
private_netmask       = "24"
private_gateway       = "192.168.100.1"
private_domain        = "internal-network.local"

public_network_label = "vDPortGroup"
public_netmask       = "25"
public_gateway       = "9.42.67.129"
public_domain        = "<PUBLIC FQDN>"
public_dns_servers   = ["9.42.106.2", "9.42.106.3"]

bastion_private_ip       = ["192.168.100.201"]
bastion_public_ip        = ["9.42.67.175"]
dns_private_ip           = ["192.168.100.202"]
dns_public_ip            = ["9.42.67.176"]
externallb_private_ip    = ["192.168.100.203"]
externallb_public_ip     = ["9.42.67.177"]
internallb_private_ip    = ["192.168.100.204"]
internallb_public_ip     = ["9.42.67.178"]
bootstrap_ip_address     = ["192.168.100.205"]
control_plane_private_ip = ["192.168.100.206", "192.168.100.207", "192.168.100.208"]
worker_ip_address        = ["192.168.100.209", "192.168.100.210", "192.168.100.211"]

dns_key_name_internal   = "rndc-key-internal"
dns_key_name_external   = "rndc-key-external"
dns_key_algorithm       = "hmac-md5"
dns_key_secret_internal = "<DNS_KEY_SECRET_INTERNAL>"
dns_key_secret_external = "<DNS_KEY_SECRET_EXTERNAL>"
dns_record_ttl          = 300

