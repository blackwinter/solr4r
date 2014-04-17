$:.unshift('lib') unless $:.first == 'lib'

require 'solr4r'

RSpec.configure { |config|
  config.expect_with(:rspec) { |c| c.syntax = [:should, :expect] }
}
