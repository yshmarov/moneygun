# frozen_string_literal: true

class MagicLinkMailer < ApplicationMailer
  def sign_in_instructions(magic_link)
    @magic_link = magic_link
    @user = magic_link.user
    mail to: @user.email, subject: t("magic_link_mailer.sign_in_instructions.subject", code: magic_link.code)
  end

  def email_change_verification(magic_link)
    @magic_link = magic_link
    @user = magic_link.user
    mail to: magic_link.new_email, subject: t("magic_link_mailer.email_change_verification.subject", code: magic_link.code)
  end

  def sudo_code(magic_link)
    @magic_link = magic_link
    @user = magic_link.user
    mail to: @user.email, subject: t("magic_link_mailer.sudo_code.subject", code: magic_link.code)
  end
end
