# frozen_string_literal: true

module OrganizationPrefill
  extend ActiveSupport::Concern

  PREFILL_TIMEOUT = 10

  private

  def prefill_organization_from_website(organization, url)
    url = normalize_url(url)
    organization.website = url

    Timeout.timeout(PREFILL_TIMEOUT) do
      metadata = OgMetadataFetcher.fetch(url)
      name = metadata["site_name"] || metadata["title"]
      organization.name = name if name.present?
      attach_og_logo(organization, metadata["favicon_url"]) if metadata["favicon_url"].present?
      attach_og_logo(organization, metadata["image_url"]) if !organization.logo.attached? && metadata["image_url"].present?
    end
  rescue Timeout::Error
    # Prefill timed out — user can still fill in details manually
  end

  def normalize_url(url)
    url = "https://#{url}" unless url.match?(%r{\Ahttps?://}i)
    url
  end

  def attach_og_logo(organization, image_url)
    response = OgMetadataFetcher.download_image(image_url)
    return if response.nil? || response.body.nil? || response.body.empty?

    content_type = response.content_type&.split(";")&.first
    return unless ApplicationRecord::IMAGE_CONTENT_TYPES.include?(content_type)

    extension = { "image/png" => ".png", "image/gif" => ".gif", "image/webp" => ".webp" }.fetch(content_type, ".jpg")

    blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new(response.body),
      filename: "logo#{extension}",
      content_type: content_type
    )
    organization.logo.attach(blob)
  rescue ActiveStorage::IntegrityError, ActiveStorage::InvariableError, IOError
    # Image download or processing failed — user can still upload manually
  end
end
