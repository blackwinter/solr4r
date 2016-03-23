require_relative 'lib/solr4r/version'

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

      dependencies: { nokogiri: '~> 1.6', 'nuggets' => '~> 1.4' },

      development_dependencies: { vcr: '~> 3.0', webmock: '~> 1.24' },

      required_ruby_version: '>= 2.0'
    }
  }}
rescue LoadError => err
  warn "Please install the `hen' gem. (#{err})"
end
