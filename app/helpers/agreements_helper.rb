# frozen_string_literal: true

module AgreementsHelper
  DOCUMENT_KEYS = {
    "Terms of Service" => :terms_of_service,
    "Privacy Notice" => :privacy_notice,
    "Data Processing Agreement" => :data_processing_agreement
  }.freeze

  def linked_agreement_statement(version)
    links = version.documents.to_h do |document|
      key = DOCUMENT_KEYS.fetch(document.fetch("title"))
      title = t("agreements.documents.#{key}")
      [:"#{key}_link", link_to(title, document.fetch("url"), target: "_blank", rel: "noopener noreferrer", class: "link")]
    end

    t("agreements.acceptances.#{version.agreement_key}.statement_html", **links)
  end

  def plain_agreement_statement(version)
    strip_tags(linked_agreement_statement(version)).squish
  end
end
