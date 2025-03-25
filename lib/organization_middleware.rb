## Multitenant Organization Middleware
#
# Included in the Rails engine if enabled.
#
# Used for setting the Organization by the first ID in the URL like Basecamp 3.
# This means we don't have to include the Organization ID in every URL helper.
class OrganizationMiddleware
  INT_MATCHER = /^\d+/
  UUID_MATCHER = /\A[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}\z/

  def initialize(app)
    @app = app
  end

  # http://example.com/12345/projects
  # http://example.com/12345-organization/projects
  def call(env)
    request = ActionDispatch::Request.new env
    _, organization_id, request_path = request.path.split("/", 3)

    if INT_MATCHER.match?(organization_id) || UUID_MATCHER.match?(organization_id)
      if (organization = Organization.find_by(id: organization_id))
        Current.organization = organization
      else
        return [ 302, { "Location" => "/" }, [] ]
      end

      request.script_name = "/#{organization_id}"
      request.path_info = "/#{request_path}"
    end

    @app.call(request.env)
  end
end
