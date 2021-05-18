sub_id = "221db4e7-cf05-4f86-8e37-a13cdbd64c14"
location = "eastus2"
rg_name = "tf-lab-eastus2-waf"
vnet_addr_space = "10.20.0.0/16"
vnet_name = "VNET-TF-Lab"
subnet_addr_prefix = "10.20.0.0/24"
subnet_name = "subnetWAF"
waf1_pip_name = "WAF01-temp-PIP"
waf2_pip_name = "WAF02-temp-PIP"
lb_name = "WAF-ELB"
waf_elb_pip_name = "WAF-ELB-PIP"
waf_subnet_nsg_name = "WAF-Subnet-NSG"
waf1_nic_name = "waf1-nic"
waf2_nic_name = "waf2-nic"
waf1_vm_name = "WAF-lab-01"
waf2_vm_name = "WAF-lab-02"
admin_password = "abcd1234ABCD"
waf_sku = "hourly"
waf_version = "10.0.101101"
waf_vm_size = "Standard_DS2_v2"
waf_signature = "Michael S Collins"
waf_email = "mcollins@barracuda.com"
waf_organization = "Barracuda Cloud Team"
