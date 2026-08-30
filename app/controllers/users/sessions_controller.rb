# frozen_string_literal: true

class Users::SessionsController < ApplicationController
  def index
    @sessions = current_user.sessions.order(created_at: :desc)
  end

  def destroy
    session_record = current_user.sessions.find(params.expect(:id))

    if session_record.id == Current.session&.id
      terminate_session
      redirect_to new_session_path, status: :see_other
    else
      session_record.destroy
      redirect_to user_sessions_path, status: :see_other
    end
  end

  def destroy_all
    current_user.sessions.where.not(id: Current.session&.id).destroy_all
    redirect_to user_sessions_path, status: :see_other
  end
end
