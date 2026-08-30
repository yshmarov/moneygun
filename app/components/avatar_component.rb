# frozen_string_literal: true

class AvatarComponent < ApplicationComponent
  VARIANTS = {
    user: { shape: "rounded-full", image_classes: "object-cover", fallback_classes: "bg-primary text-primary-content" },
    organization: { shape: "rounded", image_classes: "object-contain bg-base-300", fallback_classes: "bg-base-300 text-base-content" }
  }.freeze

  def initialize(src: nil, alt: "", initials: "?", classes: "size-8", variant: :user)
    @src = src
    @alt = alt
    @initials = initials.to_s.upcase
    @classes = classes
    @variant_config = VARIANTS.fetch(variant)
  end

  private

  def image_classes
    tw(@classes, @variant_config[:shape], @variant_config[:image_classes])
  end

  def fallback_classes
    tw("font-semibold", @variant_config[:shape], @variant_config[:fallback_classes], @classes)
  end
end
