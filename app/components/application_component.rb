# frozen_string_literal: true

class ApplicationComponent < ViewComponent::Base
  private

  def tw(*args)
    args.compact_blank.flatten.join(" ")
  end
end
