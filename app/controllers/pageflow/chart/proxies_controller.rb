require "open-uri"

module Pageflow
  module Chart
    class ProxiesController < Chart::ApplicationController
       def s3
         url = [
           ENV.fetch('S3_PROTOCOL'),
           "://",
           ENV.fetch('S3_HOST_ALIAS'),
           "/",
           ENV.fetch('S3_BUCKET'),
           "/",
           params[:path]
         ].join

         response = Rails.cache.fetch(params[:path], expires_in: 1.hour) do
           Net::HTTP.get_response( URI.parse(url).read )
         end
         send_data response.body, type: response.content_type, disposition: "inline"
       end
    end
  end
end
