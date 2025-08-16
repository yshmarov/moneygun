module Analytics
  extend ActiveSupport::Concern

  included do
    after_action :record_page_view
  end

  private

  def record_page_view
    # This is a basic example, you might need to customize some conditions.
    # For most sites, it makes no sense to record anything other than HTML.
    if response.content_type && response.content_type.start_with?("text/html")
      # Add a condition to record only your canonical domain
      # and use a gem such as crawler_detect to skip bots.
      ActiveAnalytics.record_request(request)
    end
  end
end
