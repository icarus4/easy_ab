lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'easy_ab/version'

Gem::Specification.new do |s|
  s.name        = 'easy_ab'
  s.version     = EasyAb::VERSION
  s.summary     = 'Flexible A/B testing and feature toggle for Rails'
  s.authors     = ['Gary Chu']
  s.email       = 'icarus4.chu@gmail.com'
  s.files       = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  s.homepage    = 'https://github.com/icarus4/easy_ab'
  s.license       = 'MIT'
end