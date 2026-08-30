# frozen_string_literal: true

class Avo::Actions::CompleteUserOnboarding < Avo::BaseAction
  self.name = "Complete onboarding"
  self.message = "Mark the selected user(s) as onboarded."
  self.confirm_button_label = "Complete onboarding"
  self.cancel_button_label = "Cancel"
  self.standalone = false

  def handle(query:, **)
    query.each(&:complete_onboarding!)
    succeed "Successfully completed onboarding for #{query.count} user(s)"
  end
end
