# frozen_string_literal: true

module Organizations::ScimConnectionsHelper
  def scim_base_url
    "#{request.base_url}/scim/v2"
  end
end
