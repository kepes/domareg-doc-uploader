require 'rest_client'
module Domareg
  module Doc
    module Uploader
      class DomaregApi
        def initialize(api_key, api_url)
          @api_key = api_key
          @api_url = "http://#{api_url}/api"
        end

        def query_doc_by_hash(md5)
          call_api("is_doc_uploaded/#{md5}")
        end

        def send_doc(domain, doc_name, md5)
          call_api("doc_upload", {hash: md5, domain: domain}, doc_name)
        end

        def call_api(method, form_data = {}, multipart_file = nil)
          form_data.merge!({'api_key' => @api_key})

          begin
            if multipart_file.nil?
              res = RestClient.post "#{@api_url}/#{method}", form_data
            else
              form_data['document'] = File.new(multipart_file, 'rb')
              res = RestClient.post "#{@api_url}/#{method}", form_data
            end

            return JSON::parse res.to_s
          rescue => e
            p e.inspect
            if e.response.code == 422
              return JSON::parse e.response.to_s
            else
              raise e
            end
          end

        end
      end
    end
  end
end
