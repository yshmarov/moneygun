module StaticHelper
  def markdown_to_html(markdown_text)
    renderer = Redcarpet::Render::HTML.new
    markdown = Redcarpet::Markdown.new(renderer, extensions = {})
    markdown.render(markdown_text).html_safe
  end
end
