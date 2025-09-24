class InsertFileUsagesForScrapedSites < ActiveRecord::Migration[5.2]
  # Pageflow models might have gotten out of sync with schema at this
  # point. Use local models instead.
  class MigratedPage < ActiveRecord::Base
    self.table_name = 'pageflow_pages'

    belongs_to :chapter, class_name: 'MigratedChapter'

    serialize :configuration, coder: JSON

    def configuration
      super || {}
    end
  end

  class MigratedChapter < ActiveRecord::Base
    self.table_name = 'pageflow_chapters'
    belongs_to :storyline, class_name: 'MigratedStoryline'
  end

  class MigratedStoryline < ActiveRecord::Base
    self.table_name = 'pageflow_storylines'
  end

  class MigratedFileUsage < ActiveRecord::Base
    self.table_name = 'pageflow_file_usages'
  end

  def up
    MigratedPage.where(template: 'chart').find_each do |page|
      scraped_site_id = page.configuration['scraped_site_id']
      next unless scraped_site_id

      scraped_site = Pageflow::Chart::ScrapedSite.find_by_id(scraped_site_id)

      unless scraped_site
        puts "Scraped site #{scraped_site_id} not found"
        next
      end

      revision_id = page&.chapter&.storyline&.revision_id

      unless revision_id
        puts "No revision_id for page #{page.id}"
        next
      end

      MigratedFileUsage.create(file_id: scraped_site.id,
                               file_type: 'Pageflow::Chart::ScrapedSite',
                               revision_id: revision_id)
    end
  end

  def down
    MigratedFileUsage
      .where(file_type: 'Pageflow::Chart::ScrapedSite')
      .delete_all
  end
end
