data "template_file" "consul" {
  template = <<EOF
#cloud-config
repo_update: false
repo_upgrade: false

mounts:
  - [ swap, null ]
  - [ ephemeral0, null ]
  - [ ephemeral1, null ]

write_files:
  - path: /etc/sysconfig/consul
    permissions: '0644'
    owner: root:root
    content: |
      CMD_OPTS="agent -server -bootstrap-expect=$${bootstrap_expect} -config-dir=/etc/consul -data-dir=/var/lib/consul -ui"

  - path: /etc/consul/consul.json
    permissions: '0640'
    owner: consul:root
    content: |
      {"datacenter": "$${datacenter}",
       "raft_protocol": 3,
       "data_dir":  "/var/lib/consul",
       "retry_join_ec2": {
         "region": "$${datacenter}",
         "tag_key": "$${ec2_tag_key}",
         "tag_value": "$${ec2_tag_value}"
       },
       "leave_on_terminate": true,
       "performance": {"raft_multiplier": 1}}

runcmd:
   - chkconfig consul on
   - service consul start
EOF

  vars {
    bootstrap_expect = "${var.bootstrap_expect}"
    datacenter       = "${var.datacenter}"
    ec2_tag_key      = "${var.ec2_tag_key}"
    ec2_tag_value    = "${var.ec2_tag_value}"
  }
}

resource "aws_launch_configuration" "consul" {
  name_prefix          = "${format("%s-", var.name)}"
  image_id             = "${var.image_id}"
  instance_type        = "${var.instance_type}"
  ebs_optimized        = "${var.ebs_optimized}"
  iam_instance_profile = "${var.instance_profile}"
  security_groups      = ["${var.security_groups}"]
  user_data            = "${data.template_file.consul.rendered}"

  root_block_device {
    volume_type = "gp2"
    volume_size = 10
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "consul-cluster-asg" {
  name_prefix          = "${format("%s-", var.name)}"
  vpc_zone_identifier  = ["${var.subnet_ids}"]
  launch_configuration = "${aws_launch_configuration.consul.id}"
  min_size             = "${var.min_size}"
  max_size             = "${var.max_size}"
  desired_capacity     = "${var.min_size}"
  health_check_type    = "EC2"

  tag {
    key                 = "Name"
    value               = "${var.name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "${var.ec2_tag_key}"
    value               = "${var.ec2_tag_value}"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
