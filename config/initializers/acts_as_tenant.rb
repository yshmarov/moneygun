ActsAsTenant.configure do |config|
  config.require_tenant = true

  # Customize the query for loading the tenant in background jobs
  config.job_scope = ->{ all }
end
