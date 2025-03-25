# Rails 8 SaaS Multitenancy Boilerplate

### Core features

- ✅ Registrations & Authentication (Devise + Devise invitable, but is quite easy to switch)
- ✅ Create Organizations (aka Teams, Accounts, Workspaces, Tenants)
- ✅ Invite Users to Organization & assign role (admin, member).
- ✅ Organization admin can manage organization & members
- ✅ **Organization-level subscriptions with Stripe and gem "pay"**
- ✅ Authorization
- ✅ Complete test coverage
- ✅ Basic UI design
- ✅ Nested scaffold generators for fast development (/organizations/projects)

![Moneygun features](https://i.imgur.com/QUmTexS.png)

### About Row-level route-based multitenancy in Ruby on Rails

[Teams should be an MVP feature!](https://blog.bullettrain.co/teams-should-be-an-mvp-feature/)

[Watch Screencast](https://www.youtube.com/watch?v=KMonLTvWR5g):
<a href="https://www.youtube.com/watch?v=KMonLTvWR5g"><img src="https://i3.ytimg.com/vi/KMonLTvWR5g/maxresdefault.jpg" title="Row-level route-based multitenancy in Ruby on Rails" width="50%" /><a>

### Why route-based multitenancy?

- ✅ Easy to switch between organizations
- ✅ Keep multiple organizations open in different tabs
- ✅ No hassle configuring subdomains

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

I [tried using `OrganizationMiddlewhare`](https://github.com/yshmarov/moneygun/pull/24/files#diff-44009a2f9efdafcc7cd44e1cb5e03151a74aa760c54af5c16e2cc7095ff3b0ffR7) like JumpstartPro does, but it felt too much of an **unconventional** approach.

### Design inspiration

- trello
- discord
- slack
- https://circle.so/

For example in Trello, you can have 2 unrelated boards open in 2 tabs.

## Development

### Getting started

1. Clone the template repository:

```
git clone git@github.com:yshmarov/moneygun.git your_new_project_name
```

2. Enter the project directory:

```
cd your_new_project_name
```

3. Run the configuration and setup scripts:

```
bundle install
rails db:create db:migrate
```

4. Start your application:

```
bin/dev
```

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

`Project` is an example of a well-integrated **resource** scoped to an `organization`. With pundit authorization and tests. Use it as an inspiration.

To quickly generate nested resources you can use [gem nested_scaffold](https://github.com/yshmarov/nested_scaffold)

```
rails generate nested_scaffold organization/project name
```

Generate a pundit policy:

```
rails g pundit:policy project
```

### Testing & linting

I did not focus on system tests, because the frontend can evolve a lot.

There are quite a lot of tests covering authentication, authorization, and multitenancy.

```shell
# run all tests
rails test:all
bundle exec erb_lint --lint-all -a
bundle exec rubocop -A
```

### Contributing

Feel free to raise an Issue or open a Pull Request!
