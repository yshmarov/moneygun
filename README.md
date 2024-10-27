# [Teams should be an MVP feature!](https://blog.bullettrain.co/teams-should-be-an-mvp-feature/)

### Rails 8 Multitenancy Boilerplate

Row-level route-based multitenancy in Ruby on Rails

<a href="https://www.youtube.com/watch?v=KMonLTvWR5g"><img src="https://i3.ytimg.com/vi/KMonLTvWR5g/maxresdefault.jpg" title="Row-level route-based multitenancy in Ruby on Rails" width="50%" /><a>

[Watch Screencast](https://www.youtube.com/watch?v=KMonLTvWR5g)

### Inspiration

- trello
- discord
- slack
- https://circle.so/

### Core features

- ✅ Registrations & Authentication (Devise + Devise invitable, but is quite easy to switch)
- ✅ Create Organizations (aka Teams, Organizations, Workspaces, Tenants)
- ✅ Invite Users to Organization & assign role (admin, member)
- ✅ Organization admin can manage organization & members
- ✅ Complete test coverage
- ✅ Basic UI design

### Why route-based multitenancy?

- ✅ Easy to switch between organizations
- ✅ Keep multiple organizations open in different tabs
- ✅ No hassle configuring subdomains

For example in Trello, you can have 2 unrelated boards open in 2 tabs.

### Why deep nested routes?

Yes, this can generate an "long" url like `/organizations/344/projects/4532/tasks/24342342/edit`, but it preserves the logical **hierarchy**.

```ruby
resources :organizations do
  resources :memberships
  resources :projects do
    resources :tasks do
    end
  end
end
```

I [tried using `OrganizationMiddlewhare`](https://github.com/yshmarov/askvote/pull/24/files#diff-44009a2f9efdafcc7cd44e1cb5e03151a74aa760c54af5c16e2cc7095ff3b0ffR7) like JumpstartPro does, but it felt too much of an  **unconventional** approach.

### Resource assignments and references should be to Membership and not User!

🚫 Bad

```ruby
# models/project.rb
  belongs_to :organization
  belongs_to :user
```

✅ Good

```ruby
# models/project.rb
  belongs_to :organization
  belongs_to :membership
```

I recommend scoping downstream models to `organization` too. This way you can query them more easily.

```ruby
# models/task.rb
  belongs_to :organization # <- THIS
  belongs_to :project
```

### Generators

To quickly generate nested resources you can use [gem nested_scaffold](https://github.com/yshmarov/nested_scaffold)

```
rails generate nested_scaffold organization/project name
```

Generate a pundit policy:

```
rails g pundit:policy project
```
