require 'pageflow/chart/engine'

module Pageflow
  module Chart
    def self.config
      @config ||= Chart::Configuration.new
    end

    def self.configure(&block)
      block.call(config)
    end

    def self.plugin
      Chart::Plugin.new
    end

    def self.page_type
      Chart::PageType.new
    end
  end
end
