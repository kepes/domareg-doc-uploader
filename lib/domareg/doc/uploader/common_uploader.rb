require "domareg/doc/uploader/version"
require "domareg/doc/uploader/domareg_api"
require 'json'

module Domareg
  module Doc
    module Uploader
      class CommonUploader
        def initialize(database_path, api_key, api_url, verbose)
          @database_file_name = 'domareg_upload.db'
          @database = []
          @database_name = nil
          @domareg_api = DomaregApi.new api_key, api_url

          @logger = Logger.new(STDOUT)
          @logger.level = Logger::INFO unless verbose
          @logger.level = Logger::DEBUG if verbose

          @process_count = 0
          @warn_count = 0

          @database_name = File.join(database_path, @database_file_name)
          if File.size?(@database_name)
            @database = JSON.parse(File.read(@database_name).force_encoding('utf-8'))
          end
        end

        def database_save
          File.open(@database_name, 'w') { |f| f.puts @database.to_json }
        end

        def database_find(doc_name)
          @database.each {|item| return true if item['name'] == doc_name.force_encoding('utf-8')}
          false
        end

        def database_add(doc_name, md5)
          return false if database_find(doc_name)
          @database << {'name' => doc_name.force_encoding('utf-8'), 'md5' => md5}
          database_save
        end

        def api_upload(domain, doc_name, md5)
          @domareg_api.send_doc domain, doc_name, md5
        end

        def api_query_by_hash(md5)
          @domareg_api.query_doc_by_hash(md5)
        end

        def logger
          @logger
        end

        def inc_process_count
          @process_count = @process_count + 1
        end

        def inc_warn_count
          @warn_count = @warn_count + 1
        end

        def summary
          logger.info "Processed: #{@process_count} Warning: #{@warn_count}"
        end
      end
    end
  end
end
