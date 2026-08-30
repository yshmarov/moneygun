# Mini-app pattern

The `Project` feature is Moneygun's executable example of an organization-scoped mini-app. Replace it with your first product module, keeping the boundaries below.

## Data ownership

Every tenant record belongs to both the organization and the membership that created or owns the record:

```ruby
class Invoice < ApplicationRecord
  belongs_to :organization
  belongs_to :membership

  validates :membership, same_organization: true
end
```

The database should carry foreign keys, and controllers must build through the current organization:

```ruby
@invoice = @organization.invoices.new(invoice_params.merge(membership: Current.membership))
```

Never accept `organization_id` or `membership_id` from form parameters.

## HTTP and authorization

Nest routes under `resources :organizations`, inherit from `Organizations::BaseController`, load records through `@organization`, and authorize every action with Pundit. Add controller tests for cross-tenant IDs as well as permitted behavior.

## UI and files

Use the shared section, page-title, tabs, avatar, icon, modal, and empty-state components. Attachment-owning records must implement `active_storage_accessible_to?`; the `Project` model shows the minimum tenant membership check.

## Audit events

Use namespaced actions and a mini-app name. `Project` emits `project.created`, `project.updated`, and `project.deleted` under `projects`. Store identifiers needed after deletion in metadata rather than retaining a live subject reference.

## Removing the example

Remove the project route, controller, model, policy, views, tests, navigation item, and database table together. Keep the shared tenant, authorization, audit, and file-delivery infrastructure.
