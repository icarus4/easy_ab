require 'easy_ab/rspec/spec_helper'

RSpec.configure do |config|
  config.include EasyAb::RSpec::SpecHelper, type: :controller
  config.include EasyAb::RSpec::SpecHelper, type: :helper
  config.include EasyAb::RSpec::SpecHelper, type: :request
  config.include EasyAb::RSpec::SpecHelper, type: :feature
  config.include EasyAb::RSpec::SpecHelper, type: :mailer
end