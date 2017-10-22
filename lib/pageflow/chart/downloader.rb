require 'uri'
require 'open-uri'

module Pageflow
  module Chart
    class Downloader
      attr_reader :options

      def initialize(options = {})
        @options = options
      end

      def load(url)
        file = open(make_absolute(url))
        yield(file)
      rescue OpenURI::HTTPError => exception
        Rails.logger.error "Exception loading url #{url}: #{exception.message}"
      ensure
        file.close if file
      end

      def load_all(urls, options = {})
        file = Tempfile.new(['concatenation', options.fetch(:extension, 'txt')])
        file.binmode

        begin
          urls.map do |url|
            file.write(options[:before_each]) if options.key?(:before_each)

            load(url) do |source|
              while data = source.read(16 * 1024)
                file.write(data)
              end
            end

            file.write(options[:after_each]) if options.key?(:after_each)
            file.write(options.fetch(:separator, "\n"))
          end

          file.rewind
          yield(file)
        ensure
          file.close
          file.unlink
        end
      end

      private

      def make_absolute(url)
        options[:base_url] ? URI.join(options[:base_url], url) : URI.parse(url)
      end
    end
  end
end
