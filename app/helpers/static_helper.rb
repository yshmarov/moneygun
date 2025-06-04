module StaticHelper
  def markdown_to_html(markdown_text)
    return "" if markdown_text.blank?

    # Renderer with less restrictive HTML filtering for images
    renderer = Redcarpet::Render::HTML.new(
      filter_html: false,         # Allow HTML for images to work
      no_images: false,
      no_links: false,
      hard_wrap: true,
      escape_html: false,         # Don't double-escape
      link_attributes: { target: "_blank", rel: "noopener noreferrer" }
    )

    # Enhanced extensions for better rendering
    extensions = {
      hard_wrap: true,
      autolink: true,
      no_intra_emphasis: true,
      tables: true,
      fenced_code_blocks: true,
      disable_indented_code_blocks: true,
      strikethrough: true,
      lax_spacing: true,
      space_after_headers: true,
      quote: true,
      footnotes: true,
      highlight: true,
      underline: true,
      superscript: true
    }

    markdown = Redcarpet::Markdown.new(renderer, extensions)
    html = markdown.render(markdown_text)

    # Enhance and sanitize HTML for security and styling
    secure_enhance_html(html).html_safe
  end

  private

  def secure_enhance_html(html)
    # Apply styling enhancements first, then sanitize carefully
    enhanced_html = enhance_html_styling(html)

    # Light sanitization to remove only dangerous content while preserving images/links
    sanitize_dangerous_content(enhanced_html)
  end

  def sanitize_dangerous_content(html)
    # Remove only dangerous tags while preserving images and links
    dangerous_patterns = [
      /<script[^>]*>.*?<\/script>/mi,
      /<iframe[^>]*>.*?<\/iframe>/mi,
      /<object[^>]*>.*?<\/object>/mi,
      /<embed[^>]*>/i,
      /<form[^>]*>.*?<\/form>/mi,
      /on\w+\s*=/i,  # Remove event handlers like onclick, onload, etc.
      /javascript:/i,
      /vbscript:/i,
      /data:text\/html/i
    ]

    dangerous_patterns.each do |pattern|
      html = html.gsub(pattern, "")
    end

    html
  end

  def enhance_html_styling(html)
    # Add inline styles and enhancements
    html = html.dup # Don't modify the original string

    html.gsub!(/<table>/, '<table style="margin: 1rem 0; border-collapse: collapse; width: 100%; border: 1px solid #dee2e6;">')
    html.gsub!(/<th([^>]*)>/, '<th\1 style="background-color: #f8f9fa; padding: 12px; border: 1px solid #dee2e6; font-weight: 600;">')
    html.gsub!(/<td([^>]*)>/, '<td\1 style="padding: 12px; border: 1px solid #dee2e6;">')

    # Style blockquotes
    html.gsub!(/<blockquote>/, '<blockquote style="border-left: 4px solid #007bff; padding: 1rem 1.5rem; margin: 1.5rem 0; background-color: #f8f9fa; font-style: italic; border-radius: 0.25rem;">')

    # Style code blocks
    html.gsub!(/<pre>/, '<pre style="background-color: #2d3748; color: #e2e8f0; padding: 1rem; border-radius: 0.5rem; overflow-x: auto; font-family: Monaco, Consolas, monospace; font-size: 0.875rem; margin: 1rem 0; position: relative;">')

    # Style inline code (but NOT code inside pre blocks)
    html.gsub!(/<code>([^<]+)<\/code>(?![^<]*<\/pre>)/) do |match|
      content = $1
      "<code style=\"background-color: #f1f3f4; color: #d73a49; padding: 2px 4px; border-radius: 3px; font-family: Monaco, Consolas, monospace; font-size: 0.875em;\">#{content}</code>"
    end

    # Style standalone images
    html.gsub!(/<img([^>]+)>/) do |img_tag|
      # Check if this image is inside a link (we'll handle those separately)
      next img_tag if html.match?(/<a[^>]*>\s*#{Regexp.escape(img_tag)}\s*<\/a>/)

      if img_tag.match(/src=["']([^"']+)["']/)
        src = $1
        if valid_image_url?(src)
          # Enhance the image with styling
          enhanced = img_tag.dup

          # Add loading attribute if not present
          enhanced.sub!(/<img/, '<img loading="lazy"') unless enhanced.include?("loading=")

          # Add or enhance style attribute
          if enhanced.match(/style=["']([^"']*)["']/)
            # Style exists, enhance it
            existing_style = $1
            enhanced_style = "#{existing_style}; max-width: 100%; height: auto; border-radius: 0.5rem; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); margin: 1rem 0; display: block;"
            enhanced.gsub!(/style=["'][^"']*["']/, "style=\"#{enhanced_style}\"")
          else
            # No style, add it
            enhanced.sub!(/<img/, '<img style="max-width: 100%; height: auto; border-radius: 0.5rem; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); margin: 1rem 0; display: block;"')
          end

          enhanced
        else
          "" # Remove invalid image URLs
        end
      else
        img_tag # Return as-is if no src found
      end
    end

    # Style links that contain images
    html.gsub!(/<a([^>]+)>\s*<img([^>]+)>\s*<\/a>/m) do |link_with_img|
      a_attributes = $1
      img_attributes = $2

      # Validate link
      if a_attributes.match(/href=["']([^"']+)["']/)
        href = $1
        if valid_link_url?(href)
          # Validate image
          if img_attributes.match(/src=["']([^"']+)["']/)
            img_src = $1
            if valid_image_url?(img_src)
              # Build enhanced version
              enhanced_img = "<img#{img_attributes}"

              # Add loading if not present
              enhanced_img.sub!(/<img/, '<img loading="lazy"') unless enhanced_img.include?("loading=")

              # Add or enhance style
              if enhanced_img.match(/style=["']([^"']*)["']/)
                existing_style = $1
                enhanced_style = "#{existing_style}; max-width: 100%; height: auto; border-radius: 0.5rem; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); margin: 1rem 0; display: block;"
                enhanced_img.gsub!(/style=["'][^"']*["']/, "style=\"#{enhanced_style}\"")
              else
                enhanced_img.sub!(/<img/, '<img style="max-width: 100%; height: auto; border-radius: 0.5rem; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); margin: 1rem 0; display: block;"')
              end

              enhanced_img += ">" unless enhanced_img.end_with?(">")

              "<a#{a_attributes} style=\"display: block; text-decoration: none;\">#{enhanced_img}</a>"
            else
              "" # Remove if image URL is invalid
            end
          else
            link_with_img # Return as-is if no image src
          end
        else
          "" # Remove if link URL is invalid
        end
      else
        link_with_img # Return as-is if no href
      end
    end

    # Style regular links
    html.gsub!(/<a([^>]+)>([^<]+)<\/a>/) do |link|
      attributes = $1
      content = $2

      # Extract and validate href
      if attributes.match(/href=["']([^"']+)["']/)
        href = $1
        if valid_link_url?(href)
          "<a#{attributes} style=\"color: #007bff; text-decoration: none; border-bottom: 1px solid #007bff; padding-bottom: 1px;\">#{content}</a>"
        else
          content # Just return the text if URL is invalid
        end
      else
        content
      end
    end

    # Style headers with secure anchor links
    (1..6).each do |level|
      html.gsub!(/<h#{level}>([^<]+)<\/h#{level}>/) do |header|
        text = $1
        id = generate_safe_id(text)
        "<h#{level} id=\"#{id}\" style=\"margin-top: #{level == 1 ? '2rem' : '1.5rem'}; margin-bottom: 1rem;\">#{text}</h#{level}>"
      end
    end

    # Style paragraphs
    html.gsub!(/<p>/, '<p style="margin-bottom: 1rem; line-height: 1.6;">')

    # Style lists
    html.gsub!(/<ul>/, '<ul style="margin-bottom: 1rem; padding-left: 1.5rem; list-style-type: disc; list-style-position: outside;">')
    html.gsub!(/<ol>/, '<ol style="margin-bottom: 1rem; padding-left: 1.5rem; list-style-type: decimal; list-style-position: outside;">')
    html.gsub!(/<li>/, '<li style="margin-bottom: 0.5rem; display: list-item;">')

    # Wrap in a container (using default app font and colors)
    "<div style=\"max-width: 100%;\">#{html}</div>"
  end

  def valid_image_url?(url)
    # Only allow http, https, and relative URLs
    return true if url.start_with?("/")
    return true if url.match?(/\Ahttps?:\/\//)
    false
  end

  def valid_link_url?(url)
    # Allow relative URLs and safe protocols only
    return true if url.start_with?("/")
    return true if url.start_with?("#")
    return true if url.match?(/\Ahttps?:\/\//)
    return true if url.match?(/\Amailto:/)
    false
  end

  def generate_safe_id(text)
    # Generate a safe ID for headers
    text.downcase
        .gsub(/[^a-z0-9\s-]/, "")
        .gsub(/\s+/, "-")
        .gsub(/-+/, "-")
        .gsub(/^-|-$/, "")
        .slice(0, 50) # Limit length
  end
end
