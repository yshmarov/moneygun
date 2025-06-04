module StaticHelper
  def markdown_to_html(markdown_text)
    renderer = Redcarpet::Render::HTML.new
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
      underline: true
    }
    markdown = Redcarpet::Markdown.new(renderer, extensions)
    markdown.render(markdown_text).html_safe
  end
end
