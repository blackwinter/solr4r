$:.unshift('lib') unless $:.first == 'lib'

require 'solr4r'
require 'vcr'

VCR.configure { |config|
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.cassette_library_dir = 'spec/vcr_cassettes'
}

WebMock::Config.instance.query_values_notation = :flat_array
