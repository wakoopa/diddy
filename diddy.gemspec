# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = "diddy"
  gem.version       = '0.10.0'
  gem.authors       = ["Diederick Lawson", "Marcel de Graaf"]
  gem.email         = ["diederick@altovista.nl", "mail@marceldegraaf.net"]
  gem.description   = %q{Diddy script runner}
  gem.summary       = %q{}
  gem.homepage      = "http://github.com/wakoopa/diddy"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "term/ansicolor"
end
