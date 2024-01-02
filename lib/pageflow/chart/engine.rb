require 'pageflow-public-i18n'
require 'sprockets/rails'

module Pageflow
  module Chart
    class Engine < Rails::Engine
      isolate_namespace Pageflow::Chart

      if Rails.respond_to?(:autoloaders)
        lib = root.join('lib')

        config.autoload_paths << lib
        config.eager_load_paths << lib

        initializer 'pageflow_chart.autoloading' do
          Rails.autoloaders.main.ignore(
            lib.join('generators'),
            lib.join('pageflow/chart/configuration.rb'),
            lib.join('pageflow/chart/version.rb')
          )
        end
      else
        config.autoload_paths << File.join(config.root, 'lib')
      end

      config.assets.precompile += ['pageflow/chart/custom.css', 'pageflow/chart/transparent_background.css']
      config.i18n.load_path += Dir[config.root.join('config', 'locales', '**', '*.yml').to_s]

      config.generators do |g|
        g.test_framework :rspec,:fixture => false
        g.fixture_replacement :factory_girl, :dir => 'spec/factories'
        g.assets false
        g.helper false
      end
    end
  end
end
