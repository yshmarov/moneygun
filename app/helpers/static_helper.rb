module StaticHelper
  def markdown_to_html(markdown_text)
    return "" if markdown_text.blank?

    # Basic renderer with security and styling options
    renderer = Redcarpet::Render::HTML.new(
      filter_html: false,
      no_images: false,
      no_links: false,
      hard_wrap: true,
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

    # Post-process HTML for enhanced styling and functionality
    enhance_html(html).html_safe
  end

  private

  def enhance_html(html)
    # Add inline styles and enhancements without external CSS/JS
    html.gsub!(/<table>/, '<table class="table table-striped table-bordered" style="margin: 1rem 0; border-collapse: collapse; width: 100%;">')
    html.gsub!(/<th([^>]*)>/, '<th\1 style="background-color: #f8f9fa; padding: 12px; border: 1px solid #dee2e6; font-weight: 600;">')
    html.gsub!(/<td([^>]*)>/, '<td\1 style="padding: 12px; border: 1px solid #dee2e6;">')

    # Style blockquotes
    html.gsub!(/<blockquote>/, '<blockquote style="border-left: 4px solid #007bff; padding: 1rem 1.5rem; margin: 1.5rem 0; background-color: #f8f9fa; font-style: italic; border-radius: 0.25rem;">')

    # Style code blocks with copy functionality
    html.gsub!(/<pre><code([^>]*)>/, '<div style="position: relative; margin: 1rem 0;"><pre style="background-color: #2d3748; color: #e2e8f0; padding: 1rem; border-radius: 0.5rem; overflow-x: auto; font-family: Monaco, Consolas, monospace; font-size: 0.875rem;"><code\1>')
    html.gsub!(/<\/code><\/pre>/, '</code></pre><button onclick="copyCode(this)" style="position: absolute; top: 8px; right: 8px; background: rgba(255,255,255,0.1); border: 1px solid rgba(255,255,255,0.2); color: white; padding: 4px 8px; border-radius: 4px; cursor: pointer; font-size: 12px;">📋 Copy</button></div>')

    # Style inline code
    html.gsub!(/<code>([^<]+)<\/code>/) do |match|
      content = $1
      "<code style=\"background-color: #f1f3f4; color: #d73a49; padding: 2px 4px; border-radius: 3px; font-family: Monaco, Consolas, monospace; font-size: 0.875em;\">#{content}</code>"
    end

    # Enhance images
    html.gsub!(/<img([^>]+)>/) do |img_tag|
      img_tag.sub(/<img/, '<img style="max-width: 100%; height: auto; border-radius: 0.5rem; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); margin: 1rem 0;" loading="lazy"')
    end

    # Highlight links
    html.gsub!(/<a([^>]+)>([^<]+)<\/a>/) do |link|
      attributes = $1
      content = $2
      "<a#{attributes} style=\"color: #007bff; text-decoration: none; border-bottom: 1px solid #007bff; padding-bottom: 1px; transition: all 0.2s ease;\">#{content}</a>"
    end

    # Style headers with anchor links
    (1..6).each do |level|
      html.gsub!(/<h#{level}>([^<]+)<\/h#{level}>/) do |header|
        text = $1
        id = text.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/^-|-$/, "")
        "<h#{level} id=\"#{id}\" style=\"margin-top: #{level == 1 ? '2rem' : '1.5rem'}; margin-bottom: 1rem; color: #2d3748;\">#{text} <a href=\"##{id}\" style=\"color: #cbd5e0; text-decoration: none; margin-left: 0.5rem; opacity: 0.5;\" onmouseover=\"this.style.opacity='1'\" onmouseout=\"this.style.opacity='0.5'\">#</a></h#{level}>"
      end
    end

    # Style paragraphs
    html.gsub!(/<p>/, '<p style="margin-bottom: 1rem; line-height: 1.6;">')

    # Style lists - Fix bullet/number display for Tailwind CSS
    html.gsub!(/<ul>/, '<ul style="margin-bottom: 1rem; padding-left: 1.5rem; list-style-type: disc; list-style-position: outside;">')
    html.gsub!(/<ol>/, '<ol style="margin-bottom: 1rem; padding-left: 1.5rem; list-style-type: decimal; list-style-position: outside;">')
    html.gsub!(/<li>/, '<li style="margin-bottom: 0.5rem; display: list-item;">')

    # Wrap everything in a container with copy script
    copy_script = <<~SCRIPT
      <script>
        function copyCode(button) {
          const pre = button.previousElementSibling;
          const code = pre.querySelector('code');
          const text = code.textContent || code.innerText;
      #{'    '}
          if (navigator.clipboard) {
            navigator.clipboard.writeText(text).then(() => {
              button.innerHTML = '✅ Copied!';
              setTimeout(() => button.innerHTML = '📋 Copy', 2000);
            });
          } else {
            const textArea = document.createElement('textarea');
            textArea.value = text;
            document.body.appendChild(textArea);
            textArea.select();
            document.execCommand('copy');
            document.body.removeChild(textArea);
            button.innerHTML = '✅ Copied!';
            setTimeout(() => button.innerHTML = '📋 Copy', 2000);
          }
        }
      </script>
    SCRIPT

    "<div style=\"max-width: 100%; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; color: #374151;\">#{html}</div>#{copy_script}"
  end
end
