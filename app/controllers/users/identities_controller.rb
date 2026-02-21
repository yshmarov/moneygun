# frozen_string_literal: true

class Users::IdentitiesController < ApplicationController
  before_action :set_identity, only: %i[destroy]

  def index
    @identities = current_user.identities
  end

  def destroy
    @identity.destroy
    redirect_to user_identities_path, notice: I18n.t("users.identities.destroy.success")
  end

  private

  def set_identity
    @identity = current_user.identities.find(params[:id])
  end
end
