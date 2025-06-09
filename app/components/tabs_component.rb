class TabsComponent < ViewComponent::Base
  def initialize(active_tab:, tabs: [])
    @active_tab = active_tab
    @tabs = tabs
  end

  private

  attr_reader :active_tab, :tabs

  def active_classes
    "border-primary text-primary"
  end

  def inactive_classes
    "border-transparent text-base-content/70 hover:text-base-content hover:border-base-300"
  end

  def base_classes
    "flex items-center gap-1 py-2 px-1 border-b-2 font-medium text-sm transition-colors duration-200"
  end

  def tab_classes(tab_key)
    "#{base_classes} #{active_tab == tab_key ? active_classes : inactive_classes}"
  end
end
