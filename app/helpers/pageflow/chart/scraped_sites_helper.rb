module Pageflow
  module Chart
    module ScrapedSitesHelper
      include RevisionFileHelper

      IFRAME_ATTRIBUTES = {
        style: 'width: 100%; height: 100%',
        scrolling: 'auto',
        frameborder: '0',
        align: 'aus',
        allowfullscreen: 'true',
        mozallowfullscreen: 'true',
        webkitallowfullscreen: 'true'
      }

      def scraped_site_iframe(configuration)
        data_attributes = {}

        if configuration['chart_url']
          data_attributes = {
            src: configuration['chart_url']
          }
        elsif (scraped_site = find_scraped_site(configuration))
          data_attributes = {
            src: scraped_site.html_file_url,
            customize_layout: true,
            use_custom_theme: scraped_site.use_custom_theme ? true : nil
          }
        end

        content_tag(:iframe, '', IFRAME_ATTRIBUTES.merge(data: data_attributes))
      end

      private

      def find_scraped_site(configuration)
        find_file_in_entry(ScrapedSite, configuration['scraped_site_id'])
      end
    end
  end
end
