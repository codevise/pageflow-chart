require 'nokogiri'

module Pageflow
  module Chart
    class Scraper
      attr_reader :document, :options, :javascript_urls, :javascript_body_urls, :stylesheet_urls

      def initialize(html, options = {})
        @document = Nokogiri::HTML(html)
        @options = options

        parse
        rewrite
      end

      def html
        document.to_s
      end

      def csv_url
      end

      private

      def parse
        parse_javascript_urls
        parse_javascript_body_urls
        parse_stylesheet_urls
      end

      def parse_javascript_urls
        @javascript_urls = filtered_script_tags_in_head.map do |tag|
          tag[:src]
        end
      end

      def parse_javascript_body_urls
        @javascript_body_urls = filtered_script_tags_in_body.map do |tag|
          tag[:src]
        end
      end

      def parse_stylesheet_urls
        @stylesheet_urls = css_link_tags.map do |tag|
          tag[:href]
        end
      end

      def rewrite
        filter_inline_scripts
        filter_by_selectors
        combine_script_tags_in_head
        combine_script_tags_in_body
        combine_css_link_tags
      end

      def filter_inline_scripts
        document.css('body script').each do |tag|
          if blacklisted_inline_script?(tag)
            tag.remove
          end
        end
      end

      def blacklisted_inline_script?(tag)
        options.fetch(:inline_script_blacklist, []).any? do |r|
          tag.content =~ r
        end
      end

      def filter_by_selectors
        options.fetch(:selector_blacklist, []).each do |selector|
          document.css(selector).each(&:remove)
        end
      end

      def combine_script_tags_in_head
        script_tags_to_remove = script_src_tags_in_head
        return if script_tags_to_remove.empty?

        all_script_src_tag = Nokogiri::XML::Node.new('script', document)
        all_script_src_tag[:src] = 'all.js'
        all_script_src_tag[:type] = 'text/javascript'

        script_tags_to_remove
          .first
          .add_previous_sibling(all_script_src_tag)

        script_tags_to_remove.each(&:remove)
      end

      def combine_script_tags_in_body
        script_tags_to_remove = script_src_tags_in_body
        return if script_tags_to_remove.empty?

        all_body_script_src_tag = Nokogiri::XML::Node.new('script', document)
        all_body_script_src_tag[:src] = 'all_body.js'
        all_body_script_src_tag[:type] = 'text/javascript'

        script_tags_to_remove
          .first
          .add_previous_sibling(all_body_script_src_tag)

        script_tags_to_remove.each(&:remove)
      end

      def combine_css_link_tags
        css_link_tags.each(&:remove)

        all_css_link_tag = Nokogiri::XML::Node.new('link', document)
        all_css_link_tag[:href] = 'all.css'
        all_css_link_tag[:type] = 'text/css'
        all_css_link_tag[:rel] = 'stylesheet'
        document.at_css('head') << all_css_link_tag
      end

      def filtered_script_tags_in_head
        script_src_tags_in_head.reject do |tag|
          options.fetch(:head_script_blacklist, []).any? do |regexp|
            tag[:src] =~ regexp
          end
        end
      end

      def script_src_tags_in_head
        document.css('head script[src]')
      end

      def filtered_script_tags_in_body
        script_src_tags_in_body.reject do |tag|
          options.fetch(:body_script_blacklist, []).any? do |regexp|
            tag[:src] =~ regexp
          end
        end
      end

      def script_src_tags_in_body
        document.css('body script[src]')
      end

      def css_link_tags
        document.css('head link').find_all do |tag|
          tag[:type] == 'text/css'
        end
      end
    end
  end
end
