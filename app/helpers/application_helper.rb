module ApplicationHelper
  def active_link_to(text = nil, path = nil, active_classes: '', **options, &)
    path ||= text

    classes = active_classes.presence || 'font-bold underline'
    options[:class] = class_names(options[:class], classes) if current_page?(path)

    return link_to(path, options, &) if block_given?

    link_to text, path, options
  end
end
