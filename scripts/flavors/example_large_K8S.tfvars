cluster_name = "opke-example-large"
openstack_dns_zone = "example-zone"

controller_count = "3"
openstack_controller_flavor_name = "Large_Linux"

worker_count = "20"
openstack_worker_flavor_name = "Large_Linux"

openstack_os_image_name = "coreOS"

asset_dir = "./assets"
networking = "flannel"

host_cidr = "192.168.201.0/24"

openstack_external_gateway = "some_ID"
openstack_floating_pool = "public"

openstack_ca = <<EOF
-----BEGIN CERTIFICATE-----
ThisisaFakeCA//////IIH91XURY/6jowDQYJKoZIhvcNAQELBQAwETEPMA0GA1U
AwwGRHVuZUNBMB4XDTE4MDIxMzE0NDIyMFoXDTIwMTIzMTE0MDAwMFowETEPMA0G
A1UEAwwGRHVuZUNBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAl0fY
5XhCGQZhoFjotBfZtSYVYLDrcpefpcAcHxlHpxzNOTTVqR8Mhyz2unAlppjrKHJz
zat6Cr3KITJI4oBe79Wvq80lwgzh67+mwI5ybsDx8I/Gug3kNRG0ScwzIPfKjUA7
vHS51KT712pptGKMkfDQRTanm5yAKvWIG72ZXD6ggZjm6IxE8PHNy/R/KajECnfO
ZRZvK5HV/WE4wmJipqdWOTcr/H8B13xJERZzkdxrgzfReJ+SYtsonTX6M8QbQWff
7kFLOw2+v7A/ETHd44HYtaOgTvRuo4n8uEFw5yBqosbOiFEV6Dzi76N7pkOT/OZt
X1POgCSzqr5OQ1qGZQIDAQABo2MwYTAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQY
MBaAFOTVv2rkMh6oYsNLzQPVR/Pphyu2MB0GA1UdDgQWBBTk1b9q5DIeqGLDS80D
1Ufz6YcrtjAOBgNVHQ8BAf8EBAMCAYYwDQYJKoZIhvcNAQELBQADggEBAGIsGzZZ
yuREps0XBvic3IFnC5TxVMbzdp8Q1ov/mO2TGxvLZp7k/JtDyte+3KnDlFWZJCDX
aoU1BJAm54lt1LpW3QRSe8tDcH8dMI/rBKyDlGzbQJSF3dHxMpl/JjAwdWgM9CAY
IWnVJmyNro4NXTAWEo+S9zA+08PHXqmI3puqpQLY/k7IaFDvPqgo5EaYmN2WGhNY
G/pGTcPk1PJmrQNbyupE3U42lLkwAm0huOoLLIClm5YfIvlt5hTFizIQFmuC34Fu
9C3UEEYkYN3nHMf/eA/sHL+EjR3wwsg2H4eE3qE7qphGwtqKjD8A2n5wMzWo5jxF
/fj2jv/Gig2Qi3Y=
-----END CERTIFICATE-----
EOF

kubernetes_version = "v1.9.5"
