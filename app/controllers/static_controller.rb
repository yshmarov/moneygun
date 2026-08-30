# frozen_string_literal: true

class StaticController < ApplicationController
  allow_unauthenticated_access

  def pricing; end

  def terms; end

  def privacy; end

  def refunds; end
end
