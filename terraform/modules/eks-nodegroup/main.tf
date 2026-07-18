# =============================================================================
# PayFlow Pro — EKS Node Group Module (PCI-DSS Compliant)
# IMDSv2 enforced | EBS encrypted with KMS CMK | Private subnets only
# =============================================================================

resource "aws_launch_template" "this" {
  name_prefix            = "${var.node_group_name}-"
  update_default_version = true

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.disk_size_gb
      volume_type           = "gp3"
      encrypted             = true
      kms_key_id            = var.kms_key_arn
      delete_on_termination = true
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"   # IMDSv2 mandatory
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, { Name = "${var.cluster_name}-${var.node_group_name}-node" })
  }
}

resource "aws_eks_node_group" "this" {
  cluster_name    = var.cluster_name
  node_group_name = var.node_group_name
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids

  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }

  scaling_config {
    desired_size = var.desired_size
    min_size     = var.min_size
    max_size     = var.max_size
  }

  update_config { max_unavailable_percentage = 25 }

  dynamic "taint" {
    for_each = var.taints
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  labels = var.labels
  tags   = var.tags

  lifecycle { ignore_changes = [scaling_config[0].desired_size] }
}

output "node_group_arn"  { value = aws_eks_node_group.this.arn }
output "node_group_status" { value = aws_eks_node_group.this.status }
output "asg_name" { value = aws_eks_node_group.this.resources[0].autoscaling_groups[0].name }
