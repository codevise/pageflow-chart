module Pageflow
  module Chart
    class Plugin < Pageflow::Plugin
      def configure(config)
        config.page_types.register(Chart.page_type)
        config.features.register('chart_embed_opt_in')
      end
    end
  end
end
