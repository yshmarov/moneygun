# frozen_string_literal: true

class Agreements::AcceptancesController < ApplicationController
  AGREEMENT_KEYS = %w[user_terms organization_dpa].freeze

  layout "centered"

  skip_before_action :require_user_terms
  skip_before_action :require_onboarding

  before_action :set_agreement_context
  before_action :require_user_terms_first, if: :organization_dpa?
  before_action :set_version, only: :show
  before_action :redirect_if_accepted, only: :show

  def show; end

  def create
    return head :forbidden unless acceptance_allowed?

    set_version
    unless params.dig(:acceptance, :confirmed) == "1"
      flash.now[:alert] = t("agreements.acceptances.must_accept")
      return render :show, status: :unprocessable_content
    end

    Agreements.accept!(
      @agreement_key,
      version_id: params.dig(:acceptance, :agreement_version_id),
      subject: agreement_subject,
      actor: current_user,
      authority: user_terms? ? "self" : "organization_owner",
      acceptance_statement: helpers.plain_agreement_statement(@version),
      locale: I18n.locale.to_s
    )
    current_user.update!(marketing_consent: params.dig(:acceptance, :marketing_consent)) if user_terms?

    redirect_to path_after_acceptance, status: :see_other
  rescue Agreements::VersionNotCurrent => e
    raise ActiveRecord::RecordNotFound unless e.current_version

    @version = e.current_version
    flash.now[:alert] = t("agreements.acceptances.version_changed")
    render :show, status: :unprocessable_content
  end

  private

  def set_agreement_context
    @agreement_key = params.expect(:agreement_key)
    raise ActiveRecord::RecordNotFound unless AGREEMENT_KEYS.include?(@agreement_key)

    set_organization if organization_dpa?
  end

  def set_organization
    @organization = current_user.organizations.where(memberships: { deactivated_at: nil }).find(params.expect(:organization_id))
    Current.membership = current_user.memberships.active.find_by!(organization: @organization)
    Current.organization = @organization
  end

  def require_user_terms_first
    return if current_user.terms_accepted?

    remember_agreement_return_location
    redirect_to user_terms_agreement_path, status: :see_other
  end

  def set_version
    @version = Agreements.current_version(@agreement_key)
    raise ActiveRecord::RecordNotFound unless @version
  end

  def redirect_if_accepted
    redirect_to path_after_acceptance, status: :see_other if @version.accepted_by?(agreement_subject)
  end

  def acceptance_allowed?
    user_terms? || @organization.owner?(current_user)
  end

  def agreement_subject
    user_terms? ? current_user : @organization
  end

  def user_terms?
    @agreement_key == "user_terms"
  end

  def organization_dpa?
    @agreement_key == "organization_dpa"
  end

  helper_method :acceptance_allowed?, :user_terms?, :organization_dpa?

  def path_after_acceptance
    if organization_dpa?
      onboarding = session.delete(:organization_onboarding_id) == @organization.id
      return organization_onboarding_profile_path(@organization) if onboarding

      return agreement_return_location || organization_path(@organization)
    end

    next_onboarding_path || agreement_return_location || session.delete(:return_to_after_authenticating) || default_authenticated_path
  end
end
