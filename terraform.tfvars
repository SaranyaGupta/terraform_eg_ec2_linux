iam_name = "terraform-ec2-linux"
vpc_id  = "vpc-0419802ed12eec58a"
ami_id  = "ami-0fa399d9c130ec923"
availability_zone = "us-east-2a"
instance_type = "t2.micro"
key_name  ="key_pair_terraform"
subnet_id  = "subnet-0b86a94123ccf1094"
root_volume_type ="gp2"
root_volume_size ="10"
ebs_volume_count ="2"
security_groups = ["sg1","sg2"]
instance_profile_name="test_profile"
private_ip="172.31.0.20"
region = "us-east-2"
tags= {
      InstanceIP                 = "10.33.21.25",
      Name                       = "SSB-WPX-001-P-NEW",
      OperatingSystem            = "Windows Server 2022",
      OperatingSystemSupportTeam = "test@hotmail.com",
      scheduler                  = "ec2-startstop",
      ServerProcess              = "service MS",
      ServerRoleType             = "Application",
      TicketReference            = "CHG0050760",
      DNSEntry                   = "csdasd",
      DesignDocumentLink         = "acbv"
    }
##Tags to be passed as variables. These would be appended to the pre defined tags in variables.tf
Environment="Dev"
ApplicationFunctionality = "Test"
ApplicationDescription = "To test"
ApplicationOwner="abc@hotmail.com"
ApplicationTeam="Team1"
BackupSchedule="DR7y"
BusinessTower="abc@gmail.com"
BusinessOwner="abc@gmail.com"
ServiceCriticality="High"

######Ingress and Egress rules for the New Security Groups.The number of rules should match or be 
ingress_rules =[
 
{
      from_port   = "80"
      to_port     = "80"
      protocol    = "tcp"
      cidr_block  = "192.168.161.215/32"
      description = "test"
    },
    {
      from_port   = "8084"
      to_port     = "8084"
      protocol    = "tcp"
      cidr_block  = "192.168.161.215/32"
      description = "test"
    }
]

  
#  {
#     {
#       from_port   = 80
#       to_port     = 80
#       protocol    = "tcp"
#       cidr_block  = "192.168.161.215/32"
#       description = "test"
#     },
#     {
#       from_port   = 8084
#       to_port     = 8084
#       protocol    = "tcp"
#       cidr_block  = "192.168.161.215/32"
#       description = "test"
#     },
#  }
    egress_rules = [

        {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_block  = "192.168.161.215/32"
        description = "test"
      },
      {
        from_port   = 8084
        to_port     = 8084
        protocol    = "tcp"
        cidr_block  = "192.168.161.215/32"
        description = "test"
      }

    ]
    
    


# egress_rules = {
#     test-123-udp         = [124, 125, "udp", "test", "NTP"]
#     gtg-456-tcp          = [456, 456, "tcp", "test", "Test"]
# }

# {
#  [
#     {
#       from_port   = 80  
#       to_port     = 80
#       protocol    = "tcp"
#       cidr_block  = "192.168.161.215/32"
#       description = "test"
#     },
#     {
#       from_port   = 8084
#       to_port     = 8084
#       protocol    = "tcp"
#       cidr_block  = "192.168.161.215/32"
#       description = "test"
#     },
#   ]
# }
