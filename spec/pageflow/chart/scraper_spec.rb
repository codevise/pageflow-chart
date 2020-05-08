require 'spec_helper'

module Pageflow
  module Chart
    describe Scraper do
      describe '#html' do
        it 'returns contents of parsed html' do
          html = <<-HTML
            <!DOCTYPE html>
            <html>
              <head>
                <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
              </head>
              <body>contents</body>
            </html>
          HTML
          scraper = Scraper.new(html)

          expect(scraper.html).to include('contents')
        end

        it 'filters blacklisted selectors' do
          html = <<-HTML
            <!DOCTYPE html>
            <html>
              <head>
                <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
              </head>
              <body>
                <div id="bad" class="noscript"></div>
                <div id="good"></div>
              </body>
            </html>
          HTML
          scraper = Scraper.new(html, selector_blacklist: ['body .noscript'])

          expect(HtmlFragment.new(scraper.html)).to have_tag('body #good')
          expect(HtmlFragment.new(scraper.html)).not_to have_tag('body #bad')
        end

        describe 'stylesheets in head' do
          it 'combines link tags in head' do
            html = <<-HTML
            <!DOCTYPE html>
            <html>
              <head>
                <link rel="stylesheet" type="text/css" href="/some.css">
                <link rel="stylesheet" type="text/css" href="/other.css">
              </head>
              <body>
              </body>
            </html>
            HTML
            scraper = Scraper.new(html)

            expect(HtmlFragment.new(scraper.html)).not_to have_tag('head link[href="/some.css"]')
            expect(HtmlFragment.new(scraper.html)).to have_tag('head link[href="all.css"]')
          end
        end

        describe 'scripts in head' do
          it 'combines script tags in head' do
            html = <<-HTML
            <!DOCTYPE html>
            <html>
              <head>
                <script type="text/javascript" src="/some.js"></script>
                <script type="text/javascript" src="/other.js"></script>
              </head>
              <body>
              </body>
            </html>
            HTML
            scraper = Scraper.new(html)

            expect(HtmlFragment.new(scraper.html)).not_to have_tag('head script[src="/some.js"]')
            expect(HtmlFragment.new(scraper.html)).to have_tag('head script[src="all.js"]')
          end

          it 'inserts script tag at position of first script src tag to keep position ' \
           'between inline scripts' do
            html = <<-HTML
            <!DOCTYPE html>
            <html>
              <head>
                <script id="setup">
                  // Some setup required for scripts below to execute
                </script>
                <script type="text/javascript" src="/some.js"></script>
                <script type="text/javascript" src="/other.js"></script>
                <script id="usage">
                  // Some script using stuff loading above
                </script>
              </head>
              <body>
              </body>
            </html>
            HTML
            scraper = Scraper.new(html)

            fragment = HtmlFragment.new(scraper.html)

            expect(fragment).to have_tags_in_order('head script#setup',
                                                   'head script[src="all.js"]',
                                                   'head script#usage')
          end
        end

        describe 'scripts in body' do
          it 'combines script tags in body' do
            html = <<-HTML
            <!DOCTYPE html>
            <html>
              <head>
              </head>
              <body>
                <script type="text/javascript" src="/some.js"></script>
                <script type="text/javascript" src="/other.js"></script>
              </body>
            </html>
            HTML
            scraper = Scraper.new(html)

            expect(HtmlFragment.new(scraper.html)).not_to have_tag('body script[src="/some.js"]')
            expect(HtmlFragment.new(scraper.html)).to have_tag('body script[src="all_body.js"]')
          end

          it 'inserts script tag at position of first script src tag to keep position ' \
           'between inline scripts' do
            html = <<-HTML
            <!DOCTYPE html>
            <html>
              <head>
              </head>
              <body>
                <script id="setup">
                  // Some setup required for scripts below to execute
                </script>
                <script type="text/javascript" src="/some.js"></script>
                <script type="text/javascript" src="/other.js"></script>
                <script id="usage">
                  // Some script using stuff loading above
                </script>
              </body>
            </html>
            HTML
            scraper = Scraper.new(html)

            fragment = HtmlFragment.new(scraper.html)

            expect(fragment).to have_tags_in_order('body script#setup',
                                                   'body script[src="all_body.js"]',
                                                   'body script#usage')
          end

          it 'filters blacklisted inline scripts' do
            html = <<-HTML
              <!DOCTYPE html>
              <html>
                <head>
                  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
                </head>
                <body>
                  <script id="good">window.ok = true;</script>
                  <script id="bad">alert();</script>
                </body>
              </html>
            HTML
            scraper = Scraper.new(html, inline_script_blacklist: [/alert/])

            expect(HtmlFragment.new(scraper.html)).to have_tag('body script#good')
            expect(HtmlFragment.new(scraper.html)).not_to have_tag('body script#bad')
          end
        end
      end

      describe '#javascript_urls' do
        describe 'script in head' do
          it 'returns list of urls to javascript files' do
            html = <<-HTML
            <!DOCTYPE html>
            <html>
              <head>
                <script type="text/javascript" src="/some.js"></script>
                <script type="text/javascript" src="/other.js"></script>
              </head>
              <body>
              </body>
            </html>
            HTML
            scraper = Scraper.new(html)

            expect(scraper.javascript_urls).to eq(['/some.js', '/other.js'])
          end

          it 'filters by blacklist' do
            html = <<-HTML
            <!DOCTYPE html>
            <html>
              <head>
                <script type="text/javascript" src="/some.js"></script>
                <script type="text/javascript" src="http://example.com/piwik.js"></script>
              </head>
              <body>
              </body>
            </html>
            HTML
            scraper = Scraper.new(html, head_script_blacklist: [/piwik/])

            expect(scraper.javascript_urls).to eq(['/some.js'])
          end

          it 'ignores inline scripts in head' do
            html = <<-HTML
            <!DOCTYPE html>
            <html>
              <head>
                <script type="text/javascript"></script>
              </head>
              <body>
              </body>
            </html>
            HTML
            scraper = Scraper.new(html)

            expect(scraper.javascript_urls).to eq([])
          end

          it 'ignores scripts in body' do
            html = <<-HTML
            <!DOCTYPE html>
            <html>
              <head>
              </head>
              <body>
                <script type="text/javascript" src="/some.js"></script>
              </body>
            </html>
            HTML
            scraper = Scraper.new(html)

            expect(scraper.javascript_urls).to eq([])
          end
        end

        describe 'scripts in body' do
          it 'ignores scripts in head' do
            html = <<-HTML
            <!DOCTYPE html>
            <html>
              <head>
                <script type="text/javascript" src="/some.js"></script>
              </head>
              <body>
              </body>
            </html>
            HTML
            scraper = Scraper.new(html)

            expect(scraper.javascript_body_urls).to eq([])
          end

          it 'returns list of urls to javascript files' do
            html = <<-HTML
            <!DOCTYPE html>
            <html>
              <head>
              </head>
              <body>
                <script type="text/javascript" src="/some.js"></script>
                <script type="text/javascript" src="/other.js"></script>
              </body>
            </html>
            HTML
            scraper = Scraper.new(html)

            expect(scraper.javascript_body_urls).to eq(['/some.js', '/other.js'])
          end

          it 'filters by blacklist' do
            html = <<-HTML
            <!DOCTYPE html>
            <html>
              <head>
              </head>
              <body>
                <script type="text/javascript" src="/some.js"></script>
                <script type="text/javascript" src="http://example.com/piwik.js"></script>
              </body>
            </html>
            HTML
            scraper = Scraper.new(html, body_script_blacklist: [/piwik/])

            expect(scraper.javascript_body_urls).to eq(['/some.js'])
          end

          it 'ignores inline scripts in body' do
            html = <<-HTML
            <!DOCTYPE html>
            <html>
              <head>
              </head>
              <body>
                <script type="text/javascript"></script>
              </body>
            </html>
            HTML
            scraper = Scraper.new(html)

            expect(scraper.javascript_body_urls).to eq([])
          end
        end
      end

      describe '#stylesheet_urls' do
        it 'returns list of urls to stylesheet files' do
          html = <<-HTML
            <!DOCTYPE html>
            <html>
              <head>
                <link rel="stylesheet" type="text/css" href="/some.css">
                <link rel="stylesheet" type="text/css" href="/other.css">
              </head>
              <body>
              </body>
            </html>
          HTML
          scraper = Scraper.new(html)

          expect(scraper.stylesheet_urls).to eq(['/some.css', '/other.css'])
        end

        it 'ignores non css links' do
          html = <<-HTML
            <!DOCTYPE html>
            <html>
              <head>
                <link rel="shortcut icon" href="/favicon.ico" />
              </head>
              <body>
              </body>
            </html>
          HTML
          scraper = Scraper.new(html)

          expect(scraper.stylesheet_urls).to eq([])
        end
      end
    end
  end
end
