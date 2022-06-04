# Resources for assignment at root level

# VPC / Subnets
output adlab_vpc {
    value = aws_vpc.adlab_vpc
}

output pub1 {
    value = aws_subnet.adlab_sn_pub1
}

output pub2 {
    value = aws_subnet.adlab_sn_pub2
}

output pr1 {
    value = aws_subnet.adlab_sn_pr1
}

output pr2 {
    value = aws_subnet.adlab_sn_pr2
}

# Subnet var for Jenkins module
output sn_pr2 {
    value = [var.adlab_sn_pr2]
}

# IDs
output dc01_nic_id {
    value = aws_network_interface.adlab_dc01_nic.id
}

output pub1_id {
    value = aws_subnet.adlab_sn_pub1.id
}

output pub2_id {
    value = aws_subnet.adlab_sn_pub2.id
}

output pr1_id {
    value = aws_subnet.adlab_sn_pr1.id
}

output pr2_id {
    value = aws_subnet.adlab_sn_pr2.id
}

output default_sg_id {
    value = aws_security_group.adlab_default_sg.id
}