# frozen_string_literal: true

module User::Banning
  extend ActiveSupport::Concern

  def banned?
    banned_at.present?
  end

  def ban!
    transaction do
      update!(banned_at: Time.current) unless banned?
      sessions.delete_all
    end
  end

  def unban!
    update!(banned_at: nil) if banned?
  end
end
