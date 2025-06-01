class MetricsGridComponent < ViewComponent::Base
  def initialize(metrics:)
    @metrics = metrics
  end
end
