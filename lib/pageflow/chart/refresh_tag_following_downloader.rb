require 'nokogiri'
require 'uri'

module Pageflow
  module Chart
    class RefreshTagFollowingDownloader < SimpleDelegator
      MAX_REDIRECT_COUNT = 3

      class TooManyRedirects < StandardError; end
      class NoUrlInRefreshMetaTag < StandardError; end

      def load_following_refresh_tags(url, options = {}, redirect_count = 0, &block)
        load(url, **options) do |file|
          if (redirect_url = find_refresh_meta_tag_url(file.read))
            if redirect_count >= MAX_REDIRECT_COUNT
              raise TooManyRedirects, 'Too many redirects via refresh meta tags.'
            end

            redirect_url = ensure_absolute(redirect_url, url)
            return load_following_refresh_tags(redirect_url, options, redirect_count + 1, &block)
          end

          file.rewind
          yield file if block_given?
        end
      end

      private

      def find_refresh_meta_tag_url(html)
        tag = find_refresh_meta_tag(html)

        extract_redirect_url(tag) if tag
      end

      def find_refresh_meta_tag(html)
        document = Nokogiri::HTML(html)
        document.at_css('head meta[http-equiv="REFRESH"]')
      end

      def extract_redirect_url(tag)
        if tag[:content] && tag[:content] =~ /url=/
          tag[:content].split('url=').last
        else
          raise NoUrlInRefreshMetaTag, "Could not extract url from #{tag}."
        end
      end

      def ensure_absolute(url, context_url)
        uri = URI(url)
        context_uri = URI(context_url)

        [
          uri.scheme || context_uri.scheme,
          '://',
          uri.host || context_uri.host,
          uri.path
        ].join('')
      end
    end
  end
end
