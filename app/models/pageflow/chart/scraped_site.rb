module Pageflow
  module Chart
    class ScrapedSite < ActiveRecord::Base
      include Pageflow::ReusableFile

      has_attached_file :javascript_file, Chart.config.paperclip_options(extension: 'js')
      has_attached_file :javascript_body_file, Chart.config.paperclip_options(basename: 'all_body', extension: 'js')
      has_attached_file :stylesheet_file, Chart.config.paperclip_options(extension: 'css')
      has_attached_file :html_file, Chart.config.paperclip_options(extension: 'html')
      has_attached_file :csv_file, Chart.config.paperclip_options(basename: 'data', extension: 'csv')

      do_not_validate_attachment_file_type(:javascript_file)
      do_not_validate_attachment_file_type(:javascript_body_file)
      do_not_validate_attachment_file_type(:stylesheet_file)
      do_not_validate_attachment_file_type(:html_file)
      do_not_validate_attachment_file_type(:csv_file)

      state_machine initial: 'unprocessed' do
        extend StateMachineJob::Macro

        state 'unprocessed'
        state 'processing'
        state 'processing_failed'
        state 'processed'

        event :process do
          transition 'unprocessed' => 'processing'
        end

        event :skip_reprocessing_imported_site do
          transition 'unprocessed' => 'processed'
        end

        event :reprocess do
          transition 'processed' => 'processing'
          transition 'processing_failed' => 'processing'
        end

        job ScrapeSiteJob do
          on_enter 'processing'
          result ok: 'processed'
          result error: 'processing_failed'
        end
      end

      before_create do
        self.use_custom_theme = Chart.config.use_custom_theme
        true
      end

      def csv_url
        URI.join(url, 'data.csv').to_s
      end

      def html_file_url
        return unless html_file.try(:path)
        if Chart.config.scraped_sites_root_url.present?
          File.join(Chart.config.scraped_sites_root_url, html_file.path)
        else
          html_file.url
        end
      end

      # ReusableFile-overrides:
      def url
        read_attribute(:url)
      end

      def retryable?
        processing_failed?
      end

      def ready?
        processed?
      end

      def publish!
        if html_file.present?
          skip_reprocessing_imported_site!
        else
          process!
        end
      end

      def retry!
        reprocess!
      end

      def attachments_for_export
        [javascript_file, javascript_body_file, stylesheet_file, html_file, csv_file]
      end
    end
  end
end
