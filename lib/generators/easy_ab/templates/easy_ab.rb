EasyAb.configure do |config|
  config.authorize_admin_with = -> { current_user.admin? }
end

EasyAb.experiments do |experiment|
  experiment.define_experiment :button_color, variants: ['red', 'blue', 'yellow']
  experiment.define_experiment :title, variants: ['hello', 'welcome', 'yo']
end