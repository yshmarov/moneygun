# frozen_string_literal: true

class OgMetadataFetcher
  TIMEOUT = 5
  MAX_BODY_SIZE = 500_000
  SOCIAL_DOMAINS = %w[instagram.com tiktok.com youtube.com twitter.com x.com facebook.com linkedin.com pinterest.com].freeze

  def initialize(url)
    @url = url
  end

  def self.fetch(url)
    new(url).fetch
  end

  def self.download_image(url, redirect_limit: 3)
    uri = URI.parse(url)
    download_with_redirects(uri, redirect_limit)
  rescue URI::InvalidURIError, SocketError, OpenSSL::SSL::SSLError, Timeout::Error
    nil
  end

  def self.download_with_redirects(uri, redirect_limit)
    return unless uri.is_a?(URI::HTTP) && redirect_limit.positive?

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.open_timeout = TIMEOUT
    http.read_timeout = TIMEOUT

    response = http.request(Net::HTTP::Get.new(uri))

    case response
    when Net::HTTPSuccess
      response
    when Net::HTTPRedirection
      redirect_uri = URI.parse(response["location"])
      redirect_uri = URI.join("#{uri.scheme}://#{uri.host}", response["location"]) unless redirect_uri.host
      download_with_redirects(redirect_uri, redirect_limit - 1)
    end
  end
  private_class_method :download_with_redirects

  def fetch
    uri = URI.parse(@url)
    return {} unless uri.is_a?(URI::HTTP)

    html = fetch_html(uri)
    return {} if html.blank?

    doc = Nokogiri::HTML(html)
    {
      "site_name" => og_content(doc, "og:site_name") || title_before_separator(doc),
      "title" => og_content(doc, "og:title") || doc.at_css("title")&.text&.strip,
      "description" => og_content(doc, "og:description"),
      "image_url" => og_content(doc, "og:image"),
      "favicon_url" => favicon_url(doc, uri),
      "json_ld" => extract_json_ld(doc),
      "social_links" => extract_social_links(doc),
      "main_content" => extract_main_content(doc)
    }.compact_blank
  rescue URI::InvalidURIError, SocketError, Errno::ECONNREFUSED, Errno::ECONNRESET,
         Errno::EHOSTUNREACH, OpenSSL::SSL::SSLError, Timeout::Error
    {}
  end

  private

  def fetch_html(uri, redirect_limit = 3)
    return nil if redirect_limit <= 0

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.open_timeout = TIMEOUT
    http.read_timeout = TIMEOUT

    request = Net::HTTP::Get.new(uri)
    request["User-Agent"] = "MoneygunBot/1.0"
    request["Accept"] = "text/html"

    response = http.request(request)

    case response
    when Net::HTTPSuccess
      body = response.body
      body&.bytesize.to_i > MAX_BODY_SIZE ? body.byteslice(0, MAX_BODY_SIZE) : body
    when Net::HTTPRedirection
      redirect_uri = URI.parse(response["location"])
      redirect_uri = URI.join("#{uri.scheme}://#{uri.host}", response["location"]) unless redirect_uri.host
      fetch_html(redirect_uri, redirect_limit - 1)
    end
  end

  def og_content(doc, property)
    doc.at_css("meta[property='#{property}']")&.[]("content")&.strip
  end

  def title_before_separator(doc)
    title = doc.at_css("title")&.text&.strip
    return if title.blank?

    segment = title.split(/\s*[|\-–—]\s*/, 2).first&.strip
    segment.presence
  end

  def favicon_url(doc, base_uri)
    apple = doc.at_css("link[rel='apple-touch-icon'], link[rel='apple-touch-icon-precomposed']")
    if apple&.[]("href").present?
      resolve_url(apple["href"], base_uri)
    else
      "https://www.google.com/s2/favicons?domain=#{base_uri.host}&sz=128"
    end
  end

  def resolve_url(href, base_uri)
    URI.join("#{base_uri.scheme}://#{base_uri.host}", href).to_s
  rescue URI::InvalidURIError
    nil
  end

  def extract_json_ld(doc)
    doc.css('script[type="application/ld+json"]').each do |script|
      data = JSON.parse(script.text)
      data = data["@graph"]&.first || data if data.is_a?(Hash) && data["@graph"].is_a?(Array)
      data = data.first if data.is_a?(Array)
      next unless data.is_a?(Hash)

      result = {
        "type" => data["@type"],
        "name" => data["name"],
        "description" => data["description"],
        "brand" => (data["brand"].is_a?(Hash) ? data["brand"]["name"] : data["brand"].presence),
        "price" => data.dig("offers", "price") || data.dig("offers", 0, "price"),
        "currency" => data.dig("offers", "priceCurrency") || data.dig("offers", 0, "priceCurrency")
      }.compact_blank

      return result if result.any?
    end

    nil
  rescue JSON::ParserError
    nil
  end

  def extract_social_links(doc)
    links = Set.new
    doc.css("a[href]").each do |a|
      href = a["href"].to_s.strip
      next unless href.start_with?("http")

      uri = URI.parse(href)
      host = uri.host&.downcase&.delete_prefix("www.")
      next unless SOCIAL_DOMAINS.any? { |domain| host&.end_with?(domain) }

      clean = "#{uri.scheme}://#{uri.host}#{uri.path}".chomp("/")
      links << clean
    end
    links.to_a.presence
  rescue URI::InvalidURIError
    nil
  end

  def extract_main_content(doc)
    doc.css("script, style, nav, header, footer, aside, noscript").remove

    content_node = doc.at_css("article") || doc.at_css("main") || doc.at_css("[role='main']") || doc.at_css("body")
    return nil unless content_node

    text = content_node.text.gsub(/\s+/, " ").strip
    text.truncate(2000).presence
  end
end
