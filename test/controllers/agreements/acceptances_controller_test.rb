# frozen_string_literal: true

require "test_helper"

class Agreements::AcceptancesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @organization = organizations(:one)
    @user_terms = agreements_versions(:user_terms)
    @organization_dpa = agreements_versions(:organization_dpa)
    sign_in @user
  end

  test "personal acceptance stores server-derived evidence" do
    remove_acceptance(@user_terms, @user)

    assert_difference -> { Agreements::Acceptance.count }, 1 do
      post accept_user_terms_agreement_url, params: {
        acceptance: {
          agreement_version_id: @user_terms.id,
          confirmed: "1",
          actor_key: users(:two).to_global_id.to_s,
          acceptance_statement: "Forged"
        }
      }
    end

    acceptance = @user_terms.acceptances.find_by!(subject_key: @user.to_global_id.to_s)
    assert_equal @user.to_global_id.to_s, acceptance.actor_key
    assert_equal "self", acceptance.authority
    assert_equal @user_terms.acceptance_statement, acceptance.acceptance_statement
  end

  test "a stale version records nothing" do
    remove_acceptance(@user_terms, @user)
    stale = Agreements::Version.create!(agreement_key: "user_terms", version: "old", acceptance_statement: "Old", documents: @user_terms.documents, created_at: 1.year.ago)

    assert_no_difference -> { Agreements::Acceptance.count } do
      post accept_user_terms_agreement_url, params: acceptance_params(stale)
    end
    assert_response :unprocessable_content
  end

  test "only the owner can accept the organization agreement" do
    remove_acceptance(@organization_dpa, @organization)
    non_owner = users(:two)
    @organization.memberships.create!(user: non_owner, role: "admin")
    sign_in non_owner

    assert_no_difference -> { Agreements::Acceptance.count } do
      post accept_organization_dpa_agreement_url(@organization), params: acceptance_params(@organization_dpa)
    end
    assert_response :forbidden
  end

  test "organization access requires its current DPA" do
    remove_acceptance(@organization_dpa, @organization)

    get organization_path(@organization)

    assert_redirected_to organization_dpa_agreement_path(@organization)
  end

  private

  def acceptance_params(version)
    { acceptance: { agreement_version_id: version.id, confirmed: "1" } }
  end

  def remove_acceptance(version, subject)
    Agreements::Acceptance.where(agreement_version: version, subject_key: subject.to_global_id.to_s).delete_all
  end
end
