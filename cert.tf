resource "azurerm_key_vault_certificate" "vm-cert-dsc" {
  count        = var.create_dsc_cert == true ? 1 : 0
  name         = var.name
  key_vault_id = var.key_vault_id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 4096
      key_type   = "RSA"
      reuse_key  = true
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      extended_key_usage = ["1.3.6.1.4.1.311.80.1"]

      key_usage = [
        "dataEncipherment",
        "keyEncipherment",
      ]

      subject            = "CN=${var.name}"
      validity_in_months = 12
    }
  }
}