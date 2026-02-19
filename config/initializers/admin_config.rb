# Admin configuration
Rails.application.config.admin_email = ENV.fetch("ADMIN_EMAIL", "max@mx.works")
