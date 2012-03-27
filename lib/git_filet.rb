require "git_filet/version"
require "active_support/core_ext/hash/keys"

module GitFilet
  autoload :CLI,    'git_filet/cli'
  autoload :Bisect, 'git_filet/bisect'
end