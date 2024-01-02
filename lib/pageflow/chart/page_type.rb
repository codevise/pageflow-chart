module Pageflow
  module Chart
    class PageType < Pageflow::PageType
      name 'chart'

      def view_helpers
        [ScrapedSitesHelper]
      end

      def json_seed_template
        'pageflow/chart/page_type'
      end

      def file_types
        [Chart.scraped_site_file_type]
      end
    end

    def self.scraped_site_file_type
      FileType.new(model: ScrapedSite,
                   editor_partial: 'pageflow/chart/editor/scraped_sites/scraped_site',
                   custom_attributes: {
                     url: {
                       permitted_create_param: true
                     },
                     use_custom_theme: {
                       permitted_create_param: false
                     }
                   })
    end
  end
end
