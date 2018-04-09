# controller lb

resource "openstack_lb_loadbalancer_v2" "controller_lb" {
  vip_subnet_id         = "${openstack_networking_subnet_v2.subnet.id}"
  name                  = "${var.cluster_name}_controller"
  loadbalancer_provider = "${var.openstack_lb_provider}"
}

resource "openstack_lb_pool_v2" "controller_lb_pool" {
  lb_method       = "ROUND_ROBIN"
  protocol        = "TCP"
  name            = "https"
  loadbalancer_id = "${openstack_lb_loadbalancer_v2.controller_lb.id}"
}

resource "openstack_lb_listener_v2" "controller_lb_listener" {
  default_pool_id = "${openstack_lb_pool_v2.controller_lb_pool.id}"
  loadbalancer_id = "${openstack_lb_loadbalancer_v2.controller_lb.id}"
  protocol        = "TCP"
  protocol_port   = 443
  name            = "https"
}

resource "openstack_lb_monitor_v2" "controller_lb_monitor" {
  delay       = 3
  max_retries = 1
  pool_id     = "${openstack_lb_pool_v2.controller_lb_pool.id}"
  timeout     = 2
  type        = "TCP"
  name        = "https"
}

resource "openstack_lb_member_v2" "controller_lb_members" {
  count         = "${var.controller_count}"
  address       = "${element(flatten(openstack_networking_port_v2.controller.*.all_fixed_ips), count.index)}"
  pool_id       = "${openstack_lb_pool_v2.controller_lb_pool.id}"
  protocol_port = 443
  subnet_id     = "${openstack_networking_subnet_v2.subnet.id}"
}


resource "openstack_networking_floatingip_v2" "controller_loadbalancer" {
  pool    = "${var.openstack_floating_pool}"
  port_id = "${openstack_lb_loadbalancer_v2.controller_lb.vip_port_id}"
}

# worker lb

resource "openstack_lb_loadbalancer_v2" "worker_lb" {
  vip_subnet_id         = "${openstack_networking_subnet_v2.subnet.id}"
  name                  = "${var.cluster_name}_worker"
  loadbalancer_provider = "${var.openstack_lb_provider}"
}

resource "openstack_lb_pool_v2" "worker_lb_pool" {
  lb_method       = "ROUND_ROBIN"
  protocol        = "TCP"
  name            = "https"
  loadbalancer_id = "${openstack_lb_loadbalancer_v2.worker_lb.id}"
}

resource "openstack_lb_monitor_v2" "worker_lb_monitor" {
  delay       = 10
  max_retries = 3
  pool_id     = "${openstack_lb_pool_v2.worker_lb_pool.id}"
  timeout     = 5
  type        = "TCP"
  name        = "https"
}

resource "openstack_lb_listener_v2" "worker_lb_listener_http" {
  default_pool_id = "${openstack_lb_pool_v2.worker_lb_pool.id}"
  loadbalancer_id = "${openstack_lb_loadbalancer_v2.worker_lb.id}"
  protocol        = "TCP"
  protocol_port   = 80
  name            = "https"
}

resource "openstack_lb_member_v2" "worker_lb_members_http" {
  count         = "${var.worker_count}"
  address       = "${element(openstack_networking_port_v2.worker.*.all_fixed_ips[count.index], 0)}"
  pool_id       = "${openstack_lb_pool_v2.worker_lb_pool.id}"
  protocol_port = 80
  subnet_id     = "${openstack_networking_subnet_v2.subnet.id}"
}

resource "openstack_lb_listener_v2" "worker_lb_listener_https" {
  default_pool_id = "${openstack_lb_pool_v2.worker_lb_pool.id}"
  loadbalancer_id = "${openstack_lb_loadbalancer_v2.worker_lb.id}"
  protocol        = "TCP"
  protocol_port   = 443
  name            = "https"
}

resource "openstack_lb_member_v2" "worker_lb_members_https" {
  count         = "${var.worker_count}"
  address       = "${element(flatten(openstack_networking_port_v2.worker.*.all_fixed_ips), count.index)}"
  pool_id       = "${openstack_lb_pool_v2.worker_lb_pool.id}"
  protocol_port = 443
  subnet_id     = "${openstack_networking_subnet_v2.subnet.id}"
}


resource "openstack_networking_floatingip_v2" "worker_loadbalancer" {
  pool    = "${var.openstack_floating_pool}"
  port_id = "${openstack_lb_loadbalancer_v2.worker_lb.vip_port_id}"
}
