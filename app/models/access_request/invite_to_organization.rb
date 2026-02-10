# frozen_string_literal: true

class AccessRequest::InviteToOrganization < AccessRequest
  after_create { Membership::InvitationNotifier.with(organization:, invitation: self).deliver(user) }
end
