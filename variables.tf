variable "vpc_cidr" {             # Main VPC CIDR block
  default = "10.0.0.0/16"
}

variable "public_subnets" {       # Public subnet CIDRs for load balancers
  default = ["10.0.1.0/24","10.0.2.0/24"]
}

variable "private_subnets" {      # Private subnet CIDRs for EKS nodes
  default = ["10.0.3.0/24","10.0.4.0/24"]
}

variable "node_instance_type" {   # EC2 instance type for EKS node group
  default = "t3.medium"
}

variable "node_desired_size" {    # Default number of nodes
  default = 2
}

variable "node_min_size" {        # Minimum nodes in node group
  default = 2
}

variable "node_max_size" {        # Maximum nodes in node group
  default = 3
}
