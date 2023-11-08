locals {
  volume_count   		     = var.ebs_volume_count
  security_group_enabled = var.enabled && var.security_group_enabled
  root_iops              = contains(["io1", "io2", "gp3"], var.root_volume_type) ? var.root_iops : null
  ebs_iops               = contains(["io1", "io2", "gp3"], var.ebs_volume_type) ? var.ebs_iops : null
  root_throughput        = var.root_volume_type == "gp3" ? var.root_throughput : null
  ebs_throughput         = var.ebs_volume_type == "gp3" ? var.ebs_throughput : null
  root_volume_type       = var.root_volume_type
}


data "aws_iam_policy_document" "default" {
  statement {
    sid = ""
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    effect = "Allow"
  }
}
resource "aws_iam_role" "iam" {
  name                 = var.iam_name
  path                 = "/"
  assume_role_policy   = data.aws_iam_policy_document.default.json
  #permissions_boundary = var.permissions_boundary_arn
  tags                 = var.tags
}

resource "aws_iam_instance_profile" "test_profile" {
  name = var.instance_profile_name
  role = "${aws_iam_role.iam.name}"
}
module "aws_security_group" {
  source      = "./modules/security_group"
  sg_count = length(var.security_groups)
  name = var.security_groups
  description = lookup(var.awsprops, "secgroupname")
  vpc_id      = var.vpc_id

} 
resource "aws_security_group_rule" "ingress_rules" {
  count = length(var.ingress_rules)

  type              = "ingress"
  from_port         = var.ingress_rules[count.index].from_port
  to_port           = var.ingress_rules[count.index].to_port
  protocol          = var.ingress_rules[count.index].protocol
  cidr_blocks       = [var.ingress_rules[count.index].cidr_block]
  description       = var.ingress_rules[count.index].description
  security_group_id = module.aws_security_group.id[count.index]
}


resource "aws_security_group_rule" "egress_rules" {
  count = length(var.egress_rules)
  type              = "egress"
  from_port         = var.egress_rules[count.index].from_port
  to_port           = var.egress_rules[count.index].to_port
  protocol          = var.egress_rules[count.index].protocol
  cidr_blocks       = [var.egress_rules[count.index].cidr_block]
  description       = var.egress_rules[count.index].description
  security_group_id = module.aws_security_group.id[count.index]
}



resource "aws_instance" "project-iac-ec2-linux" {
  ami                                  = var.ami_id
  availability_zone                    = var.availability_zone
  instance_type                        = var.instance_type
  disable_api_termination              = false
  associate_public_ip_address 		     = var.associate_public_ip_address
  iam_instance_profile                 = aws_iam_instance_profile.test_profile.name
  key_name                             = var.key_name
  subnet_id                            = var.subnet_id
  monitoring                           = var.monitoring
  private_ip                           = var.private_ip
  vpc_security_group_ids               = concat(module.aws_security_group.id[*],var.security_group_ids[*])
  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    iops                  = local.root_iops
    throughput            = local.root_throughput
    delete_on_termination = false
    encrypted             = true
    #kms_key_id            = var.root_block_device_kms_key_id
  }
depends_on = [module.aws_security_group.security_groups, aws_iam_role.iam]
tags = merge(tomap(var.tags),
{ApplicationFunctionality = var.ApplicationFunctionality, 
ApplicationDescription= var.ApplicationDescription,
ApplicationOwner = var.ApplicationOwner, 
ApplicationTeam = var.ApplicationTeam, 
BackupSchedule =var.BackupSchedule,
BusinessOwner = var.BusinessOwner,
ServiceCriticality =var.ServiceCriticality,
Subnet-id = var.subnet_id,
VPC-id = var.vpc_id
})

lifecycle {
     ignore_changes = [ami]
     }
}
module "ebs_volume" {
    source = "./modules/ebs_volume"
    ebs_volumes = local.volume_count

    # ... omitted
  }

resource "aws_volume_attachment" "project-iac-volume-attachment" {
  count       = local.volume_count
  device_name = var.ebs_device_name[count.index]
  volume_id   = module.ebs_volume.ebs_volume_id[count.index]
  instance_id = aws_instance.project-iac-ec2-linux.id
}
resource "aws_cloudwatch_metric_alarm" "project-iac-cloudwatch-alarm" {
  alarm_name                = "terraform-test-cloudwatch-alarm-linux"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 15
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 60
  statistic                 = "Average"
  threshold                 = 80
  alarm_description         = "This metric monitors ec2 cpu utilization"
  actions_enabled     = "true"
 alarm_actions       = ["arn:aws:automate:us-east-2:ec2:reboot"]
    dimensions = {
        InstanceId = aws_instance.project-iac-ec2-linux.id
      }
  }
