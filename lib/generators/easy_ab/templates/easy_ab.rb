EasyAb.configure do |config|
  config.authorize_admin_with = -> { current_user.admin? }
  config.user_signed_in_method = -> { user_signed_in? }
end

EasyAb.experiments do |experiment|
  experiment.define :button_color, variants: ['red', 'blue', 'yellow']
  experiment.define :title, variants: ['hello', 'welcome', 'yo']
end