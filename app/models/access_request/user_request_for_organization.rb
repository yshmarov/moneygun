class AccessRequest::UserRequestForOrganization < AccessRequest
  validates :type, presence: true

  store :resources, accessors: [ :organization_role ]
end
