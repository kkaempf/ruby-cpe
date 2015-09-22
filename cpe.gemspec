$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'cpe/version'

Gem::Specification.new do |s|
  s.name = "cpe"
  s.version = CPE::VERSION

  s.description = "Library for parsing and generating Common Platform Enumeration strings (see http://cpe.mitre.org)"
  s.summary = "CPE parsing and generating"
  s.authors = ["Chris Wuest", "Klaus Kämpf"]
  s.email = "kkaempf@suse.com"
  s.homepage = "http://github.com/kkaempf/ruby-cpe"

  s.files = `git ls-files`.split("\n")
	s.test_files = s.files.select { |f| f =~ /^test\/test_/ }

  s.license = 'MIT'
end
