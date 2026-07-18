variable "cluster_name"       { type = string }
variable "node_group_name"    { type = string }
variable "node_role_arn"      { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "kms_key_arn"        { type = string }
variable "instance_types"     { type = list(string); default = ["m6i.2xlarge"] }
variable "desired_size"       { type = number; default = 3 }
variable "min_size"           { type = number; default = 3 }
variable "max_size"           { type = number; default = 12 }
variable "disk_size_gb"       { type = number; default = 100 }
variable "labels"             { type = map(string); default = {} }
variable "taints" {
  type = list(object({ key = string; value = string; effect = string }))
  default = []
}
variable "tags" { type = map(string); default = {} }

# README
# Module: eks-nodegroup
# Provisions an EKS managed node group with:
# - CIS-hardened AL2 AMI, IMDSv2 required, EBS encrypted with KMS CMK
# - Private subnets only (PCI-DSS Req 1.3)
# - Configurable taints for PayFlow workload isolation
# Jira: SCRUM-13
