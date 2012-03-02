# -*- encoding: utf-8 -*-
require File.expand_path('../lib/git_filet/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jerry Cheung"]
  gem.email         = ["jch@whatcodecraves.com"]
  gem.description   = %q{utility for finding commits that cause regressions without knowing a starting point or ending point}
  gem.summary       = %q{utility for finding commits that cause regressions without knowing a starting point or ending point}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "git_filet"
  gem.require_paths = ["lib"]
  gem.version       = GitFilet::VERSION

  gem.add_runtime_dependency 'thor'
  gem.add_runtime_dependency 'activesupport'
end
