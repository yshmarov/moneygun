# frozen_string_literal: true

module MetaTagsHelper
  def meta_tags
    site = Rails.application.config_for(:settings)[:site]
    title = build_title(site[:name])
    description = content_for(:description).presence || site[:description]
    image = build_og_image(site[:og_image])
    url = content_for(:canonical).presence || request.original_url

    tags = [
      tag.title(title),
      tag.meta(name: "description", content: description),
      tag.meta(property: "og:title", content: title),
      tag.meta(property: "og:description", content: description),
      tag.meta(property: "og:image", content: image),
      tag.meta(property: "og:url", content: url),
      tag.meta(property: "og:site_name", content: site[:name]),
      tag.meta(property: "og:type", content: "website"),
      tag.meta(property: "og:locale", content: I18n.locale),
      tag.meta(name: "twitter:card", content: "summary_large_image"),
      tag.meta(name: "twitter:title", content: title),
      tag.meta(name: "twitter:description", content: description),
      tag.meta(name: "twitter:image", content: image),
      tag.link(rel: "canonical", href: url)
    ]

    tags << tag.meta(name: "robots", content: content_for(:robots)) if content_for(:robots).present?

    safe_join(tags, "\n")
  end

  private

  def build_title(site_name)
    parts = [content_for(:title).presence]
    parts << Current.organization&.name if defined?(Current.organization) && Current.organization&.name.present?
    parts << site_name
    parts.compact.join(" - ")
  end

  def build_og_image(default_image)
    return content_for(:og_image) if content_for(:og_image).present?

    if defined?(Current.organization) && Current.organization&.logo&.attached?
      return url_for(Current.organization.logo)
    end

    asset_url(default_image)
  end
end
