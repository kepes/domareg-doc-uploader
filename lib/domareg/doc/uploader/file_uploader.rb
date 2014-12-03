require 'domareg/doc/uploader/common_uploader'
require 'logger'

module Domareg
  module Doc
    module Uploader
      class FileUploader < CommonUploader
        def self.upload(path, vervose)
          path = File.expand_path path
          database_path = File.dirname path
          uploader = self.new database_path, api_key, api_url, verbose
          uploader.process path
          uploader.summary
        end

        def process(path)
          logger.debug "Processing: #{path}"
          inc_process_count
          domain = domain_from_path path

          if domain
            if !file_ext_valid? path
              logger.warn "Invalid file extension: #{path}"
              inc_warn_count
            elsif !file_size_valid? path
              logger.warn "Invalid file size (#{File.size(path)}): #{path}"
              inc_warn_count
            else
              upload_file domain, path
            end
          end
        end

        def domain_from_path(path)
          domain = nil
          path.split(File::SEPARATOR).each {|folder| domain = folder if folder.end_with? '.hu'}
          domain
        end

        def generate_md5(file_path)
          Digest::MD5.file(file_path).hexdigest
        end

        def upload_file(domain, file_path)
          md5 = generate_md5 file_path
          succ = database_find file_path
          if succ
            logger.debug "Uploaded, found in local database: #{domain} / #{file_path} / #{md5}"
          else
            resp_query = api_query_by_hash md5
            if resp_query['error']
              logger.debug "Already in domareg: #{domain} / #{file_path} / #{md5}"
            else
              logger.debug "Uploading: #{domain} / #{file_path} / #{md5}"
              resp_upload = api_upload domain, file_path, md5
              if resp_upload['error']
                logger.warn "Unsuccessful upload: #{resp_upload['error_message']} (#{domain} / #{file_path} / #{md5})"
                inc_warn_count
              else
                logger.info "Uploaded: #{file_path}"
                database_add file_path, md5
              end
            end
          end
        end

        def file_ext_valid?(file_path)
          %w(.jpg .pdf).include?(File.extname(file_path).downcase)
        end

        def file_size_valid?(file_path)
          File.size(file_path).between?(10.kilobytes, 2048.kilobytes)
        end
      end
    end
  end
end
