# frozen_string_literal: true

class Users::ReferralsController < ApplicationController
  def index
    @referral_code = current_user.referral_codes.first_or_create
    @referrals = current_user.referrals.includes(:referee).order(created_at: :desc)
  end
end
