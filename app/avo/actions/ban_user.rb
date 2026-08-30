# frozen_string_literal: true

class Avo::Actions::BanUser < Avo::BaseAction
  self.name = "Ban"
  self.message = "Ban the selected user(s). Banned users cannot sign in; their active sessions are terminated."
  self.confirm_button_label = "Ban"
  self.cancel_button_label = "Cancel"
  self.standalone = false

  def handle(query:, **)
    users = query.to_a
    banned = users.reject(&:banned?)
    banned.each(&:ban!)
    succeed "Banned #{banned.size} user(s)."
    redirect_to -> { users.one? ? avo.resources_user_path(users.first) : avo.resources_users_path }
  end
end
