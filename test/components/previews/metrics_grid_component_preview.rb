class MetricsGridComponentPreview < ViewComponent::Preview
  def default
    render MetricsGridComponent.new(metrics:)
  end

  private

  def metrics
    [
      {
        title: "Monthly Revenue",
        value: 150_000,
        type: :money,
        subtitle: "Up 12% from last month"
      },
      {
        title: "Active Users",
        value: 1_250,
        type: :number,
        subtitle: "Currently online"
      },
      {
        title: "Total Orders",
        value: 425,
        type: :number,
        subtitle: "This week"
      },
      {
        title: "Average Order",
        value: 8_500,
        type: :money,
        subtitle: "Per transaction"
      }
    ]
  end
end
