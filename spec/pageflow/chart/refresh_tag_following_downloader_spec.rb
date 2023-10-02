require 'spec_helper'

module Pageflow
  module Chart
    describe RefreshTagFollowingDownloader do
      describe '#load_following_refresh_tags' do
        it 'delegates to downloader if no refresh meta tag is found' do
          downloader = double(Downloader)
          refresh_tag_following_downloader = RefreshTagFollowingDownloader.new(downloader)

          original_url = 'http://datawrapper.dwcdn.net/HPKfl/2/'

          chart_html = <<-HTML
            <html><head><title>A chart</title></head></html>
          HTML

          result = ''

          allow(downloader).to receive(:load)
            .with(original_url, any_args)
            .and_yield(StringIO.new(chart_html))

          refresh_tag_following_downloader.load_following_refresh_tags(original_url) do |file|
            result = file.read
          end

          expect(result).to eq(chart_html)
        end

        it 'passes raise_on_http_error to downloader' do
          downloader = double(Downloader).as_null_object
          refresh_tag_following_downloader = RefreshTagFollowingDownloader.new(downloader)

          original_url = 'http://datawrapper.dwcdn.net/HPKfl/2/'

          expect(downloader).to receive(:load)
            .with(original_url, raise_on_http_error: true)

          refresh_tag_following_downloader.load_following_refresh_tags(original_url,
                                                                       raise_on_http_error: true)
        end

        it 'looks for refresh meta tags and loads their url instead' do
          downloader = double(Downloader)
          refresh_tag_following_downloader = RefreshTagFollowingDownloader.new(downloader)

          original_url = 'http://datawrapper.dwcdn.net/HPKfl/2/'
          target_url = 'http://other.dwcdn.net/HPKfl/5/'

          redirect_html = <<-HTML
            <html><head><meta http-equiv="REFRESH" content="0; url=http://other.dwcdn.net/HPKfl/5/"></head></html>
          HTML
          chart_html = <<-HTML
            <html><head><title>A chart</title></head></html>
          HTML

          result = ''

          allow(downloader).to receive(:load)
            .with(original_url, any_args)
            .and_yield(StringIO.new(redirect_html))

          allow(downloader).to receive(:load)
            .with(target_url, any_args)
            .and_yield(StringIO.new(chart_html))

          refresh_tag_following_downloader.load_following_refresh_tags(original_url) do |file|
            result = file.read
          end

          expect(result).to eq(chart_html)
        end

        it 'supports schema relative urls' do
          downloader = double(Downloader)
          refresh_tag_following_downloader = RefreshTagFollowingDownloader.new(downloader)

          original_url = 'http://datawrapper.dwcdn.net/HPKfl/2/'
          target_url = 'http://other.dwcdn.net/HPKfl/5/'

          redirect_html = <<-HTML
            <html><head><meta http-equiv="REFRESH" content="0; url=//other.dwcdn.net/HPKfl/5/"></head></html>
          HTML
          chart_html = <<-HTML
            <html><head><title>A chart</title></head></html>
          HTML

          result = ''

          allow(downloader).to receive(:load)
            .with(original_url, any_args)
            .and_yield(StringIO.new(redirect_html))

          allow(downloader).to receive(:load)
            .with(target_url, any_args)
            .and_yield(StringIO.new(chart_html))

          refresh_tag_following_downloader.load_following_refresh_tags(original_url) do |file|
            result = file.read
          end

          expect(result).to eq(chart_html)
        end

        it 'supports relative urls' do
          downloader = double(Downloader)
          refresh_tag_following_downloader = RefreshTagFollowingDownloader.new(downloader)

          original_url = 'http://datawrapper.dwcdn.net/HPKfl/2/'
          target_url = 'http://datawrapper.dwcdn.net/HPKfl/5/'

          redirect_html = <<-HTML
            <html><head><meta http-equiv="REFRESH" content="0; url=/HPKfl/5/"></head></html>
          HTML
          chart_html = <<-HTML
            <html><head><title>A chart</title></head></html>
          HTML

          result = ''

          allow(downloader).to receive(:load)
            .with(original_url, any_args)
            .and_yield(StringIO.new(redirect_html))

          allow(downloader).to receive(:load)
            .with(target_url, any_args)
            .and_yield(StringIO.new(chart_html))

          refresh_tag_following_downloader.load_following_refresh_tags(original_url) do |file|
            result = file.read
          end

          expect(result).to eq(chart_html)
        end

        it 'fails on too many redirects' do
          downloader = double(Downloader)
          refresh_tag_following_downloader = RefreshTagFollowingDownloader.new(downloader)

          original_url = 'http://datawrapper.dwcdn.net/HPKfl/2/'

          redirect_html = <<-HTML
            <html><head><meta http-equiv="REFRESH" content="0; url=#{original_url}"></head></html>
          HTML

          allow(downloader).to receive(:load).with(original_url, any_args) do |&block|
            block.call(StringIO.new(redirect_html))
          end

          expect {
            refresh_tag_following_downloader.load_following_refresh_tags(original_url)
          }.to raise_error(RefreshTagFollowingDownloader::TooManyRedirects)
        end

        it 'fails on invalid refresh meta tag' do
          downloader = double(Downloader)
          refresh_tag_following_downloader = RefreshTagFollowingDownloader.new(downloader)

          original_url = 'http://datawrapper.dwcdn.net/HPKfl/2/'

          redirect_html = <<-HTML
            <html><head><meta http-equiv="REFRESH" content="something strange"></head></html>
          HTML

          allow(downloader).to receive(:load).with(original_url, any_args).and_yield(StringIO.new(redirect_html))

          expect {
            refresh_tag_following_downloader.load_following_refresh_tags(original_url)
          }.to raise_error(RefreshTagFollowingDownloader::NoUrlInRefreshMetaTag)
        end

        it 'fails on refresh meta tag without content attribute' do
          downloader = double(Downloader)
          refresh_tag_following_downloader = RefreshTagFollowingDownloader.new(downloader)

          original_url = 'http://datawrapper.dwcdn.net/HPKfl/2/'

          redirect_html = <<-HTML
            <html><head><meta http-equiv="REFRESH"></head></html>
          HTML

          allow(downloader).to receive(:load).with(original_url, any_args).and_yield(StringIO.new(redirect_html))

          expect {
            refresh_tag_following_downloader.load_following_refresh_tags(original_url)
          }.to raise_error(RefreshTagFollowingDownloader::NoUrlInRefreshMetaTag)
        end
      end
    end
  end
end
