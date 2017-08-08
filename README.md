# Easy AB

Easy, flexible A/B testing tool for Rails.

* Design for web.
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
Easy AB is under development and is in beta phase. Be sure to test before integrating with your production app.

# Installation & Setup

* Add `gem 'easy_ab'` to your application's Gemfile and run `bundle install`.
* Run `bin/rails g easy_ab:install`. Migration file and initializer will copy to your app folder.
* Run `bin/rake db:migrate`
* Edit `config/initializers/easy_ab.rb` to setup basic configurations.

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

# Usage

Define your experiments in `config/initializers/easy_ab.rb`

Say, if you have an experiment named 'button_color', with three equal weighted variants: red, blue, green.

Define your experiment as follows:

``` ruby
EasyAb.experiments do |experiment|
  experiment.define :button_color, variants: ['red', 'blue', 'green']
end
```

Then you will be able to use `ab_test` helpers in controller or view:

```ruby
color = ab_test(:button_color)
```

or pass a block

```erb
<% ab_test(:button_color) do |color| %>
  <button class="<%= color %>">Click Me!</button>
<% end %>
```

For admin, specify a variant with url parameters makes debugging super easy:

```
?ab_test[button_color]=blue
```

You can specify weightings of each variant:

``` ruby
EasyAb.experiments do |experiment|
  experiment.define :button_color,
    variants: ['red', 'blue', 'green'],
    weights:  [8, 1, 1] # Weights of variants can be any positive integers
end
```

Then 80% of your users will see red button, and 10% for blue and green respectively.

Also, by specifying rules with Proc or lambda, you can split users with more flexible way. For example, for the first 100 signed up users, if you wanna provide extra 90 days of paid features for them whenever they subscribe your service, and other users for extra 30 days:

```ruby
EasyAb.experiments do |experiment|
  experiment.define :extra_vip_duration,
    variants: ['90', '30'], # Variants are stored as string, you have handle the type conversion by yourself
    rules: [
      -> { current_user.id <= 100 },
      -> { current_user.id > 100 }
    ]
end
```

NOTICE: rules are executed in the order you defined in `config/initializers/easy_ab.rb`. If there are intersections among your rules, the former rule will be applied. For example:

```ruby
EasyAb.experiments do |experiment|
  experiment.define :extra_vip_duration,
    variants: ['90', '30']
    rules: [
      -> { current_user.id <= 20 },
      -> { current_user.id > 10 }
    ]

# Users with id between 11 to 20 matches both lambdas, will get variant '90'
```

Keep in mind that `ab_test()` helper always returns String. You have to handle the type conversion by yourself.

```erb
# In controller
@extra_vip_duration = ab_test(:extra_vip_duration).to_i.days
```

You can dump experiment data of current user to analytics services (Mixpanel, Google Analytics, etc.) by `all_participated_experiments`

```erb
# In your view
<script type="text/javascript">
  mixpanel.track("My Event", {
    <% all_participated_experiments.each do |experiment, variant| %>
      "<%= experiment %>": "<%= variant %>",
    <% end %>
  })
</script>
```

The return format of `all_participated_experiments`

```ruby
{
  'experiment 1' => 'variant 1',
  'experiment 2' => 'variant 2',
  ...
}
```

# Others
## Type of experiments
Both String and Symbol are valid when defining experiment or passing to `ab_test`.

```ruby
# Define experiment as symbol (recommended)
EasyAb.experiments do |experiment|
  experiment.define :button_color,
    variants: ['red', 'blue', 'green']
end

# In view/controller
ab_test(:button_color)  # OK (recommended)
ab_test('button_color') # OK
```

```ruby
# Define experiment as String
EasyAb.experiments do |experiment|
  experiment.define 'button_color',
    variants: ['red', 'blue', 'green']
end

# In view/controller
ab_test(:button_color)  # OK
ab_test('button_color') # OK
```

## Type of variants
You can define variants as Symbol, but `ab_test()` always returns String

```ruby
# Define variants as symbol
EasyAb.experiments do |experiment|
  experiment.define :button_color,
    variants: [:red, :blue, :green]
end

# In view/controller
ab_test(:button_color).class # => String
```

# Todo
* Add comparisons with existing A/B testing gems
* Convertion rate
* Test code