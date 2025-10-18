class Users::ReferralsController < ApplicationController
  def index
    @referral_code = current_user.referral_codes.first_or_create
    @metrics = [
      { title: t('users.referrals.index.clicks'), subtitle: t('users.referrals.index.clicks_description'), value: @referral_code.visits_count, type: :number },
      { title: t('users.referrals.index.referrals'), subtitle: t('users.referrals.index.referrals_description'), value: @referral_code.referrals.count, type: :number },
      { title: t('users.referrals.index.completed'), subtitle: t('users.referrals.index.completed_description'), value: @referral_code.referrals.completed.count, type: :number }
    ]
    @referrals = current_user.referrals.order(created_at: :desc)
  end
end
