# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pageflow/chart/version'

Gem::Specification.new do |spec|
  spec.name          = 'pageflow-chart'
  spec.version       = Pageflow::Chart::VERSION
  spec.authors       = ['Codevise Solutions Ltd']
  spec.email         = ['info@codevise.de']
  spec.summary       = 'Pagetype for Embedded Datawrapper Charts'
  spec.homepage      = 'https://github.com/codevise/pageflow-chart'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '~> 2.1'

  spec.add_runtime_dependency 'pageflow', '~> 12.2.x'
  spec.add_runtime_dependency 'nokogiri', '~> 1.0'
  spec.add_runtime_dependency 'paperclip', '~> 4.2'
  spec.add_runtime_dependency 'state_machine', '~> 1.2'
  spec.add_runtime_dependency 'state_machine_job', ['>= 0.2', '< 2']
  spec.add_runtime_dependency 'pageflow-public-i18n', '~> 1.0'

  spec.add_development_dependency 'bundler', '~> 1.0'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rspec-rails', '~> 3.0'
  spec.add_development_dependency 'factory_girl_rails', '~> 4.5'
  spec.add_development_dependency 'sqlite3', '~> 1.3'
  spec.add_development_dependency 'webmock', '~> 3.0'

  # Semantic versioning rake tasks
  spec.add_development_dependency 'semmy', '~> 1.0'
end
