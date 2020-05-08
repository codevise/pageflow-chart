require 'spec_helper'

module Pageflow::Chart
  describe ScrapedSite do
    describe '#csv_url' do
      it 'replaces base filename of url with data.csv' do
        scraped_site = ScrapedSite.new(url: 'http://example.com/foo/index.html')

        expect(scraped_site.csv_url).to eq('http://example.com/foo/data.csv')
      end

      it 'appends data.csv to directory url' do
        scraped_site = ScrapedSite.new(url: 'http://example.com/foo/')

        expect(scraped_site.csv_url).to eq('http://example.com/foo/data.csv')
      end
    end

    it 'copies use_custom_theme flag from config on create' do
      Pageflow::Chart.config.use_custom_theme = true
      scraped_site_with_custom_theme = create(:scraped_site)

      Pageflow::Chart.config.use_custom_theme = false
      scraped_site_without_custom_theme = create(:scraped_site)

      expect(scraped_site_with_custom_theme.use_custom_theme).to eq(true)
      expect(scraped_site_without_custom_theme.use_custom_theme).to eq(false)
    end

    it 'exposes all attachments for export' do
      scraped_site = ScrapedSite.new(url: 'http://example.com/foo/index.html')

      expect(scraped_site.attachments_for_export.map(&:name))
        .to eq(%i[javascript_file javascript_body_file stylesheet_file html_file csv_file])
    end

    describe '#publish!' do
      it 'transitions state to processing for new site' do
        scraped_site = ScrapedSite.new(url: 'http://example.com/foo/index.html')

        scraped_site.publish!

        expect(scraped_site.state).to eq('processing')
      end

      it 'transitions state to processed if html file is already set ' \
         '(e.g. for sites that have been created via entry import)' do
        scraped_site = ScrapedSite.new(url: 'http://example.com/foo/index.html',
                                       html_file_file_name: 'index.html')

        scraped_site.publish!

        expect(scraped_site.state).to eq('processed')
      end
    end

    describe '#retryable?' do
      it 'is true if processing_failed' do
        scraped_site = ScrapedSite.new(url: 'http://example.com/foo/index.html',
                                       state: 'processing_failed')

        expect(scraped_site).to be_retryable
      end

      it 'is false if processed' do
        scraped_site = ScrapedSite.new(url: 'http://example.com/foo/index.html',
                                       state: 'processed')

        expect(scraped_site).not_to be_retryable
      end
    end

    describe '#retry!' do
      it 'transitions state to processing if processing_failed' do
        scraped_site = ScrapedSite.new(url: 'http://example.com/foo/index.html',
                                       state: 'processing_failed')

        scraped_site.retry!

        expect(scraped_site.state).to eq('processing')
      end
    end
  end
end
