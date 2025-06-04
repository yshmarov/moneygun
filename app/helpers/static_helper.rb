module StaticHelper
  def markdown_to_html(markdown_text)
    return "" if markdown_text.blank?

    renderer = Redcarpet::Render::HTML.new(
      filter_html: false,
      no_images: false,
      no_links: false,
      hard_wrap: true,
      escape_html: false,
      link_attributes: { target: "_blank", rel: "noopener noreferrer" }
    )

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
    tag.div(class: "prose text-base-content max-w-none sm:max-w-prose overflow-x-auto") do
      markdown.render(markdown_text).html_safe
    end
  end
end
