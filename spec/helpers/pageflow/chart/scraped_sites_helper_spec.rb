require 'spec_helper'

require 'pageflow/used_file_test_helper'

module Pageflow
  module Chart
    describe ScrapedSitesHelper do
      include UsedFileTestHelper

      before { Pageflow::Chart.config.use_custom_theme = false }

      it 'renders iframe with data-src attribute for scraped site' do
        scraped_site = create_used_file(:scraped_site, :processed)

        html = scraped_site_iframe('scraped_site_id' => scraped_site.perma_id)

        iframe = Capybara.string(html).find('iframe')
        expect(iframe['data-src']).to match(%r{original/index\.html})
      end

      it 'renders no data-custom-theme attribute by default' do
        scraped_site = create_used_file(:scraped_site, :processed)

        html = scraped_site_iframe('scraped_site_id' => scraped_site.perma_id)

        iframe = Capybara.string(html).find('iframe')
        expect(iframe['data-use-custom-theme']).to be_blank
        expect(iframe['data-customize-layout']).to eq('true')
      end

      it 'renders data-custom-theme if site has custom theme' do
        Pageflow::Chart.config.use_custom_theme = true
        scraped_site = create_used_file(:scraped_site, :processed)

        html = scraped_site_iframe('scraped_site_id' => scraped_site.perma_id)

        iframe = Capybara.string(html).find('iframe')
        expect(iframe['data-use-custom-theme']).to eq('true')
        expect(iframe['data-customize-layout']).to eq('true')
      end

      it 'renders iframe with data-src attribute for chart_url' do
        html = scraped_site_iframe('chart_url' => 'https://example.com/chart')

        iframe = Capybara.string(html).find('iframe')
        expect(iframe['data-src']).to eq('https://example.com/chart')
      end

      it 'renders no data-custom-theme attribute for chart_url' do
        html = scraped_site_iframe('chart_url' => 'https://example.com/chart')

        iframe = Capybara.string(html).find('iframe')

        expect(iframe['data-customize-layout']).to be_blank
        expect(iframe['data-use-custom-theme']).to be_blank
      end
    end
  end
end
