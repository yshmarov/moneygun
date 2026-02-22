# frozen_string_literal: true

xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
  [
    root_url,
    pricing_url,
    terms_url,
    privacy_url,
    refunds_url
  ].each do |url|
    xml.url do
      xml.loc url
    end
  end
end
