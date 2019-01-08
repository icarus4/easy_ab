# If you want to change definitions of experiments without restart rails server in development mode
# Set config.reload_classes_only_on_change to false in config/environments/development.rb
#
# And add the following snippets in your application.rb
#
# initializer_file = Rails.root.join('config', 'initializers', 'easy_ab.rb')
# reloader = ActiveSupport::FileUpdateChecker.new([initializer_file]) do
#   load initializer_file
# end
# ActiveSupport::Reloader.to_prepare do
#   reloader.execute
# end
#
EasyAb.experiments.reset

EasyAb.configure do |config|
  # Define how to check whether current user is signed in or not
  config.user_signed_in_method = -> { user_signed_in? }

  # Define how to get current user's id
  config.current_user_id = -> { current_user.id }

  # Define how to check whether current user is admin or not
  # Only admin can switch variant by url parameters
  config.authorize_admin_with = -> { current_user.admin? }
end

EasyAb.experiments do |experiment|
  # experiment.define :button_color,
  #   variants: ['red', 'blue', 'yellow'],
  #   weights:  [8, 1, 1]

  # experiment.define :extra_vip_duration,
  #   variants: ['90', '30'], # Variants stored as String, you must handle the conversion in your app by yourself
  #   rules: [
  #     -> { current_user.id <= 100 },
  #     -> { current_user.id > 100 }
  #   ]
end