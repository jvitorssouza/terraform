resource "time_sleep" "wait_30_seconds_db" {
  depends_on = [azurerm_linux_virtual_machine.terraform_mysql-vm]
  create_duration = "30s"
}

resource "null_resource" "upload_db" {
    provisioner "file" {
        connection {
            type = "ssh"
            user = "azureuser"
            password = "adminuser@2021"
            host = azurerm_public_ip.terraform_mysql-publicip.ip_address
        }
        source = "config"
        destination = "/home/azureuser"
    }
    depends_on = [time_sleep.wait_30_seconds_db]
}

resource "null_resource" "install-mysql" {
    triggers = {
        order = null_resource.upload_db.id
    }
    provisioner "remote-exec" {
        connection {
            type = "ssh"
            user = "azureuser"
            password = "adminuser@2021"
            host = azurerm_public_ip.terraform_mysql-publicip.ip_address
        }
        
        inline = [
            "sudo apt-get update",
            "sudo apt-get install -y mysql-server-5.7",
            "sudo mysql < /home/azureuser/user.sql",
            "sudo cp -f /home/azureuser/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf",
            "sudo service mysql restart",
            "sleep 20",
        ]
    }
}