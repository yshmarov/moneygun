module StaticHelper
  def markdown_to_html(markdown_text)
    return "" if markdown_text.blank?

    render_options = {
      filter_html: false,
      hard_wrap: true,
      link_attributes: { target: "_blank", rel: "noopener noreferrer" },
      prettify: true,
      space_after_headers: true
    }

    renderer = Redcarpet::Render::HTML.new(render_options)

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
    tag.article(class: "prose dark:prose-invert") do
      sanitize(markdown.render(markdown_text), tags: %w[p h1 h2 h3 h4 h5 h6 ul ol li strong em code pre blockquote a br hr table tr td th], attributes: %w[href target rel])
    end
  end
end
