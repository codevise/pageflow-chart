require 'spec_helper'

module Pageflow
  module Chart
    describe Downloader do
      describe '#load' do
        it 'yields io containing downloaded files' do
          downloader = Downloader.new
          result = ''

          stub_request(:get, "http://example.com/a").to_return(status: 200, body: 'aaa')

          downloader.load('http://example.com/a') do |io|
            result = io.read
          end

          expect(result).to eq("aaa")
        end

        it 'ignores HTTP response 404' do
          downloader = Downloader.new
          result = ''

          stub_request(:get, "http://example.com/a").to_return(status: 404, body: 'aaa')

          downloader.load('http://example.com/a') do |io|
            result = io.read
          end

          expect(result).to eq("")
        end

        it 'derives protocol from base_url' do
          downloader = Downloader.new(base_url: 'http://someother.com')
          result = ''

          stub_request(:get, "http://example.com/a").to_return(status: 200, body: 'aaa')

          downloader.load('//example.com/a') do |io|
            result = io.read
          end

          expect(result).to eq("aaa")
        end

        it 'handles urls relative to base_url' do
          downloader = Downloader.new(base_url: 'http://example.com/b/')
          result = ''

          stub_request(:get, "http://example.com/a").to_return(status: 200, body: 'aaa')

          downloader.load('../a') do |io|
            result = io.read
          end

          expect(result).to eq("aaa")
        end
      end

      describe '#load_all' do
        it 'yields io containing concatenation of downloaded files' do
          downloader = Downloader.new
          result = ''

          stub_request(:get, "http://example.com/a").to_return(status: 200, body: 'aaa')
          stub_request(:get, "http://example.com/b").to_return(status: 200, body: 'bbb')

          downloader.load_all(['http://example.com/a', 'http://example.com/b']) do |io|
            result = io.read
          end

        end

        it 'allows to specify temp file extension' do
          downloader = Downloader.new
          path = ''

          stub_request(:get, "http://example.com/a").to_return(status: 200, body: 'aaa')

          downloader.load_all(['http://example.com/a'], extension: '.js') do |file|
            path = file.path
          end

          expect(File.extname(path)).to eq('.js')
        end

        it 'allows to specify seprator string' do
          downloader = Downloader.new
          result = ''

          stub_request(:get, "http://example.com/a").to_return(status: 200, body: 'aaa')
          stub_request(:get, "http://example.com/b").to_return(status: 200, body: 'bbb')

          downloader.load_all(['http://example.com/a', 'http://example.com/b'], separator: ';') do |io|
            result = io.read
          end

          expect(result).to eq("aaa;bbb;")
        end

        it 'allows to wrap file contents' do
          downloader = Downloader.new
          result = ''

          stub_request(:get, "http://example.com/a").to_return(status: 200, body: 'aaa')
          stub_request(:get, "http://example.com/b").to_return(status: 200, body: 'bbb')

          downloader.load_all(['http://example.com/a', 'http://example.com/b'],
                              before_each: 'try {',
                              after_each: '} catch(e) {}') do |io|
            result = io.read
          end

          expect(result).to eq("try {aaa} catch(e) {}\ntry {bbb} catch(e) {}\n")
        end
      end
    end
  end
end
