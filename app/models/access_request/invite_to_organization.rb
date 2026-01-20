# frozen_string_literal: true

class AccessRequest::InviteToOrganization < AccessRequest
  after_create { Membership::InvitationNotifier.with(organization:).deliver(user) }
end
