require 'domareg/doc/uploader/folder_uploader'
require 'optparse'

options = {
  verbose: false,
  check: true
}

optparse = OptionParser.new do |opts|
  opts.banner = "Usage: domareg_upload [path|file] [options]"
  opts.separator ""
  opts.separator "Specific options:"

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = true
  end

  opts.on("-k APIKEY", "--key APIKEY", "Domareg API key") do |v|
    options[:key] = v
  end

  opts.on("-s SERVER", "--server DOMAIN", "Domreg server") do |v|
    options[:server] = v
  end

  opts.on("-c", "--check", "Turn off file date check on folder scan") do |v|
    options[:check] = false
  end

  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end

  opts.on_tail("--version", "Show version") do
    puts Domareg::Doc::Uploader::VERSION
    exit
  end
end

begin
  optparse.parse!
  mandatory = [:key, :server]
  missing = mandatory.select{ |param| options[param].nil? }
  if not missing.empty?
    puts "Missing options: #{missing.join(', ')}"
    puts optparse
    exit
  end
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
  puts $!.to_s
  puts optparse
  exit
end

path = ARGV[0] || '.'
Domareg::Doc::Uploader::FolderUploader.upload(path, options[:key], options[:server], options[:verbose], options[:check])
