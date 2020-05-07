module Pageflow
  module Chart
    FactoryBot.define do
      factory :scraped_site, class: 'Pageflow::Chart::ScrapedSite' do
        url { 'MyString' }

        trait :processed do
          state { 'processed' }

          javascript_file { File.open(Engine.root.join('spec', 'fixtures', 'all.js')) }
          javascript_body_file { File.open(Engine.root.join('spec', 'fixtures', 'all_body.js')) }
          stylesheet_file { File.open(Engine.root.join('spec', 'fixtures', 'all.css')) }
          html_file { File.open(Engine.root.join('spec', 'fixtures', 'index.html')) }
          csv_file { File.open(Engine.root.join('spec', 'fixtures', 'data.csv')) }
        end
      end
    end
  end
end
