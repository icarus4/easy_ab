# Easy AB

Easy, flexible A/B testing tool for Rails.

* Design for web
* Use your database to keep users' testing info to seamlessly handle the transition from guest to signed in user. You don't need to prepare extra stack like Redis or something else.
* Grouping your users to your predefined variants with very easy and flexible way:
  * Random with equal weightings.
  * Random with predefined weightings.
  * Define Proc(s) to setup your rules. Something like "sign up for 1 month to variant A, others to variant B", "user with odd id to variant A, with even id to variant B", ...
  Example of using proc to define rules:

  ```ruby
  # Example 1
  variants: ['variant A', 'variant B']
  rules: [
    -> { current_user.created_at <= 1.month.ago },
    -> { current_user.created_at > 1.month.ago },
  ]

  # Example 2
  variants: ['variant A', 'variant B']
  rules: [
    -> { current_user.id.odd? },
    -> { current_user.id.even? },
  ]
  ```
  and you can change your rules at any time without affecting existing users, they always see the same variant
* Convenient APIs to
  * check your view for different variants
  * output all experiments and the corresponding variants for your users. It's very useful when sending data to analytics services like Google Anayltics, Mixpanel, Kissmetrics, ...
* No DSL, just setup your rules with pure Ruby (and Rails) :)

# Notice
Easy AB is under development. Currently don't use in your production app.

# Why Easy AB?
## Comparisons
### Split
### Field Test
### Flipper
### ...

# Installation

* Add `gem 'easy_ab'` to your application's Gemfile and run `bundle install`.
* Run `bin/rails g easy_ab:install`. Migration file and initializer will copy to your app folder.
* Run `bin/rake db:migrate`

# Setup

Edit `config/initializers/easy_ab.rb` to setup basic configurations.

```ruby
EasyAb.configure do |config|
  # Tell the gem how to check whether current user is signed in or not
  config.user_signed_in_method = -> { user_signed_in? }

  # Tell the gem how to get current user's id
  config.current_user_id = -> { current_user.id }

  # Tell the gem how to check whether current user is admin or not
  # Only admin can switch variant by url parameters
  config.authorize_admin_with = -> { current_user.admin? }
end
```

# Getting Started

Setup your experiments in `config/initializers/easy_ab.rb`

Say, if you have an experiment named 'button color', with three equal weighted variants: red, blue, green.

Define your experiment as follows:

``` ruby
EasyAb.experiments do |experiment|
  experiment.define :title_color, variants: ['red', 'blue', 'green']
end
```

Then you will be able to use the following helpers in controller or view:

```ruby
color = ab_test(:title_color)
```

or pass a block

```erb
<% ab_test(:title_color) do |color| %>
  <h1 class="<%= color %>">Welcome!</h1>
<% end %>
```

For admin, specify a variant with url parameters makes debugging super easy:

```
?ab_test[title_color]=blue
```