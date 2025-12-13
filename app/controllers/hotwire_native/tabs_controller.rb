# frozen_string_literal: true

# in the Native app, define absolute paths
# redirect these absolute paths to the correct controller actions based on context like
# current_user, current_organization, etc.
# redirect_to user_path(current_user) if current_user&.present?
class HotwireNative::TabsController < ApplicationController
  # def tab0
  #   redirect_to root_path
  # end

  def tab1
    redirect_to root_path
    # redirect_to projects_path
  end

  def tab2
    redirect_to root_path
    # redirect_to edit_user_registration_path
  end

  # add more tabs (max 5)
  # def tab3; end
  # def tab4; end
  # def tab5; end
end
