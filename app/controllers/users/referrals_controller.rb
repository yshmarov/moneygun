# frozen_string_literal: true

class Users::ReferralsController < ApplicationController
  def index
    @referral_code = current_user.referral_codes.first_or_create
    @metrics = [
      { title: t(".clicks"), subtitle: t(".clicks_description"), value: @referral_code.visits_count, type: :number },
      { title: t(".referrals"), subtitle: t(".referrals_description"), value: @referral_code.referrals.count, type: :number },
      { title: t(".completed"), subtitle: t(".completed_description"), value: @referral_code.referrals.completed.count, type: :number }
    ]
    @referrals = current_user.referrals.order(created_at: :desc)
  end
end
