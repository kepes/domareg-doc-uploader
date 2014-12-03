require 'domareg/doc/uploader/file_uploader'
require 'find'
require 'active_support/all'

module Domareg
  module Doc
    module Uploader
      class FolderUploader < FileUploader

        def self.upload(folder, api_key, api_url, verbose, check_date)
          folder = File.expand_path folder
          uploader = self.new folder, api_key, api_url, verbose, check_date
          uploader.process folder
          uploader.summary
        end

        def initialize(database_path, api_key, api_url, verbose, check_date)
          super database_path, api_key, api_url, verbose
          @check_date = check_date
        end

        alias :process_file :process
        def process(folder)
          domain = nil
          files = []
          Find.find(folder) do |path|
            if File.basename(path)[0] == ?. && File.directory?(path)
              Find.prune

            elsif File.file?(path) && domain && file_ext_valid?(path)
              # file méret direkt nincs ellenőrizve, hogy legyen róla log bejegyzés a file_uploader-ben
              files << path

            elsif File.directory? path
              process_all_files(files)
              files = []
              domain = domain_from_path path
            end
          end
          process_all_files(files)
        end

        def process_all_files(files)
          unless files.empty?
            max_date = nil
            files.each { |f| max_date = File.mtime(f) if max_date.nil? || File.mtime(f) > max_date  }
            files.each do |f|
              if File.mtime(f) > max_date - 1.month || !@check_date
                process_file f
              else
                inc_process_count
                inc_warn_count
                logger.warn "Date out of range! (date: #{File.mtime(f)} max_date: #{max_date} file: #{f})"
              end
            end
          end
        end
      end
    end
  end
end
