require File.expand_path(%q{../lib/solr4r/version}, __FILE__)

begin
  require 'hen'

  Hen.lay! {{
    gem: {
      name:         %q{solr4r},
      version:      Solr4R::VERSION,
      summary:      %q{A Ruby client for Apache Solr.},
      description:  %q{Access the Apache Solr search server from Ruby.},
      author:       %q{Jens Wille},
      email:        %q{jens.wille@gmail.com},
      license:      %q{AGPL-3.0},
      homepage:     :blackwinter,
      dependencies: { nokogiri: '~> 1.6' },

      required_ruby_version: '>= 1.9.3'
    }
  }}
rescue LoadError => err
  warn "Please install the `hen' gem. (#{err})"
end
