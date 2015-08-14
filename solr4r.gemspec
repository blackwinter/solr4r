# -*- encoding: utf-8 -*-
# stub: solr4r 0.0.7 ruby lib

Gem::Specification.new do |s|
  s.name = "solr4r"
  s.version = "0.0.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Jens Wille"]
  s.date = "2015-08-14"
  s.description = "Access the Apache Solr search server from Ruby."
  s.email = "jens.wille@gmail.com"
  s.extra_rdoc_files = ["README", "COPYING", "ChangeLog"]
  s.files = ["COPYING", "ChangeLog", "README", "Rakefile", "TODO", "lib/solr4r.rb", "lib/solr4r/builder.rb", "lib/solr4r/client.rb", "lib/solr4r/client/admin.rb", "lib/solr4r/client/query.rb", "lib/solr4r/client/update.rb", "lib/solr4r/document.rb", "lib/solr4r/endpoints.rb", "lib/solr4r/logging.rb", "lib/solr4r/request.rb", "lib/solr4r/response.rb", "lib/solr4r/result.rb", "lib/solr4r/uri_extension.rb", "lib/solr4r/version.rb", "spec/solr4r/builder_spec.rb", "spec/solr4r/client_spec.rb", "spec/spec_helper.rb", "spec/vcr_cassettes/Solr4R_Client/requests/_get/should_get_/select.yml", "spec/vcr_cassettes/Solr4R_Client/requests/_get/should_get_/select_CSV.yml", "spec/vcr_cassettes/Solr4R_Client/requests/_get/should_get_/select_FOO.yml", "spec/vcr_cassettes/Solr4R_Client/requests/_get/should_get_/select_JSON_result.yml", "spec/vcr_cassettes/Solr4R_Client/requests/_get/should_get_/select_JSON_string.yml", "spec/vcr_cassettes/Solr4R_Client/requests/_get/should_get_/select_XML.yml", "spec/vcr_cassettes/Solr4R_Client/requests/_get/should_not_get_/foo.yml", "spec/vcr_cassettes/Solr4R_Client/requests/_json/should_get_/select_JSON.yml", "spec/vcr_cassettes/Solr4R_Client/requests/_json/should_get_/select_JSON_with_wt_string_override.yml", "spec/vcr_cassettes/Solr4R_Client/requests/_json/should_get_/select_JSON_with_wt_symbol_override.yml"]
  s.homepage = "http://github.com/blackwinter/solr4r"
  s.licenses = ["AGPL-3.0"]
  s.post_install_message = "\nsolr4r-0.0.7 [2015-08-14]:\n\n* Fixed Solr4R::Client::Query#json_query for multiple +fq+ parameters.\n* Renamed Solr4R::Response#extend_hash to Solr4R::Response#result_object.\n* Renamed Solr4R::Client::Update#delete_by_id to\n  Solr4R::Client::Update#delete_id.\n* Renamed Solr4R::Client::Update#delete_by_query to\n  Solr4R::Client::Update#delete_query.\n* Renamed Solr4R::Client::Update#delete_all! to\n  Solr4R::Client::Update#delete_all.\n* Added alias Solr4R::Client::Update#clear for\n  Solr4R::Client::Update#delete_all.\n* Added Solr4R::Client#escape.\n* Added Solr4R::Client#query_string.\n* Added Solr4R::Client#local_params_string.\n* Updated Solr4R::Client::Query#more_like_this_q for Solr 5.3.0.\n  * Fixes handling of multiple field names\n    (SOLR-7143[https://issues.apache.org/jira/browse/SOLR-7143]).\n  * Adds support for other MoreLikeThisHandler options\n    (SOLR-7639[https://issues.apache.org/jira/browse/SOLR-7639]).\n* Refactored Solr4R::Endpoints#initialize to accept options hash.\n* Refactored Solr4R::Builder#delete to use Solr4R::Client#query_string for\n  query hashes.\n\n"
  s.rdoc_options = ["--title", "solr4r Application documentation (v0.0.7)", "--charset", "UTF-8", "--line-numbers", "--all", "--main", "README"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3")
  s.rubygems_version = "2.4.8"
  s.summary = "A Ruby client for Apache Solr."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nokogiri>, ["~> 1.6"])
      s.add_runtime_dependency(%q<nuggets>, ["~> 1.3"])
      s.add_development_dependency(%q<vcr>, ["~> 2.9"])
      s.add_development_dependency(%q<webmock>, ["~> 1.21"])
      s.add_development_dependency(%q<hen>, [">= 0.8.3", "~> 0.8"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
    else
      s.add_dependency(%q<nokogiri>, ["~> 1.6"])
      s.add_dependency(%q<nuggets>, ["~> 1.3"])
      s.add_dependency(%q<vcr>, ["~> 2.9"])
      s.add_dependency(%q<webmock>, ["~> 1.21"])
      s.add_dependency(%q<hen>, [">= 0.8.3", "~> 0.8"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
    end
  else
    s.add_dependency(%q<nokogiri>, ["~> 1.6"])
    s.add_dependency(%q<nuggets>, ["~> 1.3"])
    s.add_dependency(%q<vcr>, ["~> 2.9"])
    s.add_dependency(%q<webmock>, ["~> 1.21"])
    s.add_dependency(%q<hen>, [">= 0.8.3", "~> 0.8"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
  end
end
