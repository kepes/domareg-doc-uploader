# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'domareg/doc/uploader/version'

Gem::Specification.new do |spec|
  spec.name          = "domareg-doc-uploader"
  spec.version       = Domareg::Doc::Uploader::VERSION
  spec.authors       = ["kepes.peter"]
  spec.email         = ["kepes.peter@codeplay.hu"]
  spec.description   = %q{Send documents from local drive to domareg.hu with API call. It cares about duplicates and check file hash against already stored documents. Script works on a folders rescursively where one folder name should be a domain name.}
  spec.summary       = %q{Send documents from local drive to domareg.hu}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_runtime_dependency "rest_client"
  spec.add_runtime_dependency "activesupport"
  spec.add_development_dependency "rubocop"
end
