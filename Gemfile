source "https://rubygems.org"
gemspec

gem 'rake'
gem 'pry'

# gem 'fhir_models', :path => '../fhir_models'
gem 'fhir_models', :git => 'https://github.com/fhir-crucible/fhir_models.git', :branch => 'profiling'

group :test do
  gem 'simplecov', :require => false
  gem 'minitest', '~> 5.3'
  gem 'minitest-reporters'
  gem 'awesome_print', :require => 'ap'
end
