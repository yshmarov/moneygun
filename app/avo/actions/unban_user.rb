# frozen_string_literal: true

class Avo::Actions::UnbanUser < Avo::BaseAction
  self.name = "Unban"
  self.message = "Unban the selected user(s). They will be able to sign in again."
  self.confirm_button_label = "Unban"
  self.cancel_button_label = "Cancel"
  self.standalone = false

  def handle(query:, **)
    users = query.select(&:banned?)
    users.each(&:unban!)
    succeed "Unbanned #{users.size} user(s)."
    redirect_to -> { avo.resources_users_path }
  end
end
