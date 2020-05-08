class AddJavascriptBodyAttachmentToScrapedSite < ActiveRecord::Migration[5.2]
  def change
    add_attachment :pageflow_chart_scraped_sites, :javascript_body_file
  end
end
