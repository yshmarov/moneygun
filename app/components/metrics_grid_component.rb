class MetricsGridComponent < ViewComponent::Base
  def initialize(metrics:)
    @metrics = metrics
  end

  private

  def processed_metrics
    @metrics.map do |metric|
      if metric[:type] == :money
        end_value = metric[:value].to_f / 100
        display_value = helpers.number_to_currency(end_value)
      else
        end_value = metric[:value]
        display_value = helpers.number_with_delimiter(metric[:value])
      end

      metric.merge(
        end_value: end_value,
        display_value: display_value
      )
    end
  end
end
