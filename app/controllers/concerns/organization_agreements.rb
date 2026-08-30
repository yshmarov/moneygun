# frozen_string_literal: true

module OrganizationAgreements
  private

  def require_organization_agreement
    return unless Current.organization

    redirected = require_agreement(
      "organization_dpa",
      subject: Current.organization,
      location: organization_dpa_agreement_path(Current.organization)
    )
    skip_authorization if redirected && respond_to?(:skip_authorization, true)
  end
end
