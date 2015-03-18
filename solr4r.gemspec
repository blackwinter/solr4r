# -*- encoding: utf-8 -*-
# stub: solr4r 0.0.6 ruby lib

Gem::Specification.new do |s|
  s.name = "solr4r"
  s.version = "0.0.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Jens Wille"]
  s.date = "2015-03-18"
  s.description = "Access the Apache Solr search server from Ruby."
  s.email = "jens.wille@gmail.com"
  s.extra_rdoc_files = ["README", "COPYING", "ChangeLog"]
  s.files = ["COPYING", "ChangeLog", "README", "Rakefile", "TODO", "lib/solr4r.rb", "lib/solr4r/builder.rb", "lib/solr4r/client.rb", "lib/solr4r/client/admin.rb", "lib/solr4r/client/query.rb", "lib/solr4r/client/update.rb", "lib/solr4r/document.rb", "lib/solr4r/endpoints.rb", "lib/solr4r/logging.rb", "lib/solr4r/request.rb", "lib/solr4r/response.rb", "lib/solr4r/result.rb", "lib/solr4r/uri_extension.rb", "lib/solr4r/version.rb", "spec/solr4r/builder_spec.rb", "spec/solr4r/client_spec.rb", "spec/spec_helper.rb"]
  s.homepage = "http://github.com/blackwinter/solr4r"
  s.licenses = ["AGPL-3.0"]
  s.post_install_message = "\nsolr4r-0.0.6 [unreleased]:\n\n* Extracted Solr4R::Endpoints from Solr4R::Client.\n* Extracted Solr4R::Client::Admin, Solr4R::Client::Query and\n  Solr4R::Client::Update from Solr4R::Client.\n* Added core to Solr4R::Client.default_uri and adjusted\n  Solr4R::Client::DEFAULT_SYSTEM_PATH.\n* Added Solr4R::Client::Admin#cores.\n* Added Solr4R::Client::Admin#fields.\n* Added Solr4R::Client::Admin#analyze_document.\n* Added Solr4R::Client::Admin#analyze_field.\n* Added Solr4R::Client::Query#json_document.\n* Added Solr4R::Client::Query#more_like_this_h (using the {request\n  handler}[https://cwiki.apache.org/confluence/display/solr/MoreLikeThis]).\n* Added Solr4R::Client::Query#more_like_this_q (using the {query\n  parser}[https://cwiki.apache.org/confluence/display/solr/Other+Parsers#OtherParsers-MoreLikeThisQueryParser]).\n* Added support for {local\n  params}[https://cwiki.apache.org/confluence/display/solr/Local+Parameters+in+Queries]\n  to Solr4R::Client.query_string.\n* Extended Solr4R::RequestUriExtension#query_pairs to skip +nil+ values.\n* Extended Solr4R::RequestUriExtension#query_pairs to allow control over\n  nested key's value (via +:_+).\n* Refactored Solr4R::Document#more_like_this to use\n  Solr4R::Client#more_like_this.\n* Refactored Solr4R::Builder#delete to use Solr4R::Client.query_string for\n  query hashes.\n* Refactored Solr4R::Request preparation; dropped\n  Solr4R::HTTPRequestExtension.\n* Refactored Solr4R::Response initialization.\n\n"
  s.rdoc_options = ["--title", "solr4r Application documentation (v0.0.6)", "--charset", "UTF-8", "--line-numbers", "--all", "--main", "README"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3")
  s.rubygems_version = "2.4.6"
  s.summary = "A Ruby client for Apache Solr."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nokogiri>, ["~> 1.6"])
      s.add_runtime_dependency(%q<nuggets>, [">= 1.0.1", "~> 1.0"])
      s.add_development_dependency(%q<hen>, [">= 0.8.1", "~> 0.8"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
    else
      s.add_dependency(%q<nokogiri>, ["~> 1.6"])
      s.add_dependency(%q<nuggets>, [">= 1.0.1", "~> 1.0"])
      s.add_dependency(%q<hen>, [">= 0.8.1", "~> 0.8"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
    end
  else
    s.add_dependency(%q<nokogiri>, ["~> 1.6"])
    s.add_dependency(%q<nuggets>, [">= 1.0.1", "~> 1.0"])
    s.add_dependency(%q<hen>, [">= 0.8.1", "~> 0.8"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
  end
end
