# frozen_string_literal: true

Rails.application.config.to_prepare do
  ActiveStorage::Blobs::RedirectController.include(ActiveStorage::VirusScanGuard)
  ActiveStorage::Blobs::ProxyController.include(ActiveStorage::VirusScanGuard)
  ActiveStorage::Representations::RedirectController.include(ActiveStorage::VirusScanGuard)
  ActiveStorage::Representations::ProxyController.include(ActiveStorage::VirusScanGuard)
end
