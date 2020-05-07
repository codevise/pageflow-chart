module Pageflow
  module Chart
    class ScrapeSiteJob < ActiveJob::Base
      queue_as :scraping

      include StateMachineJob

      def perform_with_result(scraped_site,
                              _options = {},
                              downloader: downloader_for(scraped_site))
        downloader.load_following_refresh_tags(scraped_site.url,
                                               raise_on_http_error: true) do |file|
          scraper = Scraper.new(file.read, Chart.config.scraper_options)
          scraped_site.html_file = StringIOWithContentType.new(
            scraper.html,
            file_name: 'file.html',
            content_type: 'text/html'
          )

          downloader.load_all(scraper.javascript_urls,
                              extension: '.js',
                              before_each: begin_try_catch,
                              after_each: end_try_catch) do |javascript_file|
            scraped_site.javascript_file = javascript_file
          end

          downloader.load_all(scraper.javascript_body_urls,
                              extension: '.js',
                              before_each: begin_try_catch,
                              after_each: end_try_catch) do |javascript_body_file|
            scraped_site.javascript_body_file = javascript_body_file
          end

          downloader.load_all(scraper.stylesheet_urls,
                              extension: '.css',
                              separator: "\n;") do |stylesheet_file|
            scraped_site.stylesheet_file = stylesheet_file
          end
        end

        downloader.load(scraped_site.csv_url) do |file|
          scraped_site.csv_file = file
        end

        :ok
      rescue Downloader::HTTPError
        :error
      end

      private

      def downloader_for(scraped_site)
        RefreshTagFollowingDownloader.new(Downloader.new(base_url: scraped_site.url))
      end

      def begin_try_catch
        ";try {\n"
      end

      def end_try_catch
        "\n} catch(e) { console.log('Datawrapper raised: ' + (e.message || e)); }\n"
      end
    end

    class StringIOWithContentType < StringIO
      def initialize(string, options)
        super(string)
        @options = options
      end

      def content_type
        @options.fetch(:content_type)
      end

      def original_filename
        @options.fetch(:file_name)
      end
    end
  end
end
