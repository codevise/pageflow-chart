module Pageflow
  module Chart
    module ScrapedSitesHelper
      IFRAME_ATTRIBUTES = {
        style: 'width: 100%; height: 100%',
        scrolling: 'auto',
        frameborder: '0',
        align: 'aus',
        allowfullscreen: 'true',
        mozallowfullscreen: 'true',
        webkitallowfullscreen: 'true'
      }

      def scraped_site_iframe(scraped_site_id)
        scraped_site = ScrapedSite.find_by_id(scraped_site_id)
        data_attributes = {}

        if scraped_site
          data_attributes = {
            src: scraped_site.html_file_url
          }

          if scraped_site.use_custom_theme
            data_attributes[:use_custom_theme] = true
          end
        end

        content_tag(:iframe, '', IFRAME_ATTRIBUTES.merge(data: data_attributes))
      end
    end
  end
end
