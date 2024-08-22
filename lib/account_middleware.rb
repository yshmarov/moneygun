## Multitenant Account Middleware
#
# Included in the Rails engine if enabled.
#
# Used for setting the Account by the first ID in the URL like Basecamp 3.
# This means we don't have to include the Account ID in every URL helper.
class AccountMiddleware
  INT_MATCHER = /^\d+/
  UUID_MATCHER = /\A[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}\z/

  def initialize(app)
    @app = app
  end

  # http://example.com/12345/projects
  # http://example.com/12345-account/projects
  def call(env)
    request = ActionDispatch::Request.new env
    _, account_id, request_path = request.path.split("/", 3)

    if INT_MATCHER.match?(account_id) || UUID_MATCHER.match?(account_id)
      if (account = Account.find_by(id: account_id))
        Current.account = account
      else
        return [302, {"Location" => "/"}, []]
      end

      request.script_name = "/#{account_id}"
      request.path_info = "/#{request_path}"
    end

    @app.call(request.env)
  end
end
