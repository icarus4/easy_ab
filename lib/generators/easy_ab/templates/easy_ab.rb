EasyAb.configure do |config|
  config.user_signed_in_method = -> { user_signed_in? }
  config.current_user_id = -> { current_user.id }
  config.authorize_admin_with = -> { current_user.admin? }
end

EasyAb.experiments do |experiment|
  experiment.define :button_color, variants: ['red', 'blue', 'yellow']
  experiment.define :title, variants: ['hello', 'welcome', 'yo']
end