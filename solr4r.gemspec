# -*- encoding: utf-8 -*-
# stub: solr4r 0.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "solr4r"
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Jens Wille"]
  s.date = "2015-12-14"
  s.description = "Access the Apache Solr search server from Ruby."
  s.email = "jens.wille@gmail.com"
  s.extra_rdoc_files = ["README", "COPYING", "ChangeLog"]
  s.files = ["COPYING", "ChangeLog", "README", "Rakefile", "TODO", "lib/solr4r.rb", "lib/solr4r/builder.rb", "lib/solr4r/client.rb", "lib/solr4r/client/admin.rb", "lib/solr4r/client/query.rb", "lib/solr4r/client/update.rb", "lib/solr4r/document.rb", "lib/solr4r/endpoints.rb", "lib/solr4r/logging.rb", "lib/solr4r/request.rb", "lib/solr4r/response.rb", "lib/solr4r/result.rb", "lib/solr4r/uri_extension.rb", "lib/solr4r/version.rb", "spec/solr4r/builder_spec.rb", "spec/solr4r/client_spec.rb", "spec/spec_helper.rb", "spec/vcr_cassettes/Solr4R_Client/requests/_get/should_get_/select.yml", "spec/vcr_cassettes/Solr4R_Client/requests/_get/should_get_/select_CSV.yml", "spec/vcr_cassettes/Solr4R_Client/requests/_get/should_get_/select_FOO.yml", "spec/vcr_cassettes/Solr4R_Client/requests/_get/should_get_/select_JSON_result.yml", "spec/vcr_cassettes/Solr4R_Client/requests/_get/should_get_/select_JSON_string.yml", "spec/vcr_cassettes/Solr4R_Client/requests/_get/should_get_/select_XML.yml", "spec/vcr_cassettes/Solr4R_Client/requests/_get/should_not_get_/foo.yml", "spec/vcr_cassettes/Solr4R_Client/requests/_json/should_get_/select_JSON.yml", "spec/vcr_cassettes/Solr4R_Client/requests/_json/should_get_/select_JSON_with_wt_string_override.yml", "spec/vcr_cassettes/Solr4R_Client/requests/_json/should_get_/select_JSON_with_wt_symbol_override.yml"]
  s.homepage = "http://github.com/blackwinter/solr4r"
  s.licenses = ["AGPL-3.0"]
  s.post_install_message = "\nsolr4r-0.2.0 [2015-12-14]:\n\n* Updated Solr4R::Client::Query#more_like_this_q for Solr 5.4.0.\n  * Adds support for boost option and excludes current document from results\n    (SOLR-7912[https://issues.apache.org/jira/browse/SOLR-7912]).\n\n"
  s.rdoc_options = ["--title", "solr4r Application documentation (v0.2.0)", "--charset", "UTF-8", "--line-numbers", "--all", "--main", "README"]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0")
  s.rubygems_version = "2.5.1"
  s.summary = "A Ruby client for Apache Solr."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nokogiri>, ["~> 1.6"])
      s.add_runtime_dependency(%q<nuggets>, ["~> 1.4"])
      s.add_development_dependency(%q<vcr>, ["~> 2.9"])
      s.add_development_dependency(%q<webmock>, ["~> 1.22"])
      s.add_development_dependency(%q<hen>, [">= 0.8.3", "~> 0.8"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
    else
      s.add_dependency(%q<nokogiri>, ["~> 1.6"])
      s.add_dependency(%q<nuggets>, ["~> 1.4"])
      s.add_dependency(%q<vcr>, ["~> 2.9"])
      s.add_dependency(%q<webmock>, ["~> 1.22"])
      s.add_dependency(%q<hen>, [">= 0.8.3", "~> 0.8"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
    end
  else
    s.add_dependency(%q<nokogiri>, ["~> 1.6"])
    s.add_dependency(%q<nuggets>, ["~> 1.4"])
    s.add_dependency(%q<vcr>, ["~> 2.9"])
    s.add_dependency(%q<webmock>, ["~> 1.22"])
    s.add_dependency(%q<hen>, [">= 0.8.3", "~> 0.8"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
  end
end
