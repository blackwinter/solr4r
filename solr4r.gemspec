# -*- encoding: utf-8 -*-
# stub: solr4r 0.3.1 ruby lib

Gem::Specification.new do |s|
  s.name = "solr4r".freeze
  s.version = "0.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Jens Wille".freeze]
  s.date = "2016-06-06"
  s.description = "Access the Apache Solr search server from Ruby.".freeze
  s.email = "jens.wille@gmail.com".freeze
  s.extra_rdoc_files = ["README".freeze, "COPYING".freeze, "ChangeLog".freeze]
  s.files = ["COPYING".freeze, "ChangeLog".freeze, "README".freeze, "Rakefile".freeze, "TODO".freeze, "lib/solr4r.rb".freeze, "lib/solr4r/batch.rb".freeze, "lib/solr4r/builder.rb".freeze, "lib/solr4r/client.rb".freeze, "lib/solr4r/client/admin_mixin.rb".freeze, "lib/solr4r/client/query_mixin.rb".freeze, "lib/solr4r/client/update_mixin.rb".freeze, "lib/solr4r/document.rb".freeze, "lib/solr4r/endpoints.rb".freeze, "lib/solr4r/logging.rb".freeze, "lib/solr4r/query.rb".freeze, "lib/solr4r/request.rb".freeze, "lib/solr4r/response.rb".freeze, "lib/solr4r/result.rb".freeze, "lib/solr4r/uri_extension.rb".freeze, "lib/solr4r/version.rb".freeze, "spec/solr4r/builder_spec.rb".freeze, "spec/solr4r/client_spec.rb".freeze, "spec/spec_helper.rb".freeze, "spec/vcr_cassettes/Solr4R_Client/requests/_get/should_get_/select.yml".freeze, "spec/vcr_cassettes/Solr4R_Client/requests/_get/should_get_/select_CSV.yml".freeze, "spec/vcr_cassettes/Solr4R_Client/requests/_get/should_get_/select_FOO.yml".freeze, "spec/vcr_cassettes/Solr4R_Client/requests/_get/should_get_/select_JSON_result.yml".freeze, "spec/vcr_cassettes/Solr4R_Client/requests/_get/should_get_/select_JSON_string.yml".freeze, "spec/vcr_cassettes/Solr4R_Client/requests/_get/should_get_/select_XML.yml".freeze, "spec/vcr_cassettes/Solr4R_Client/requests/_get/should_not_get_/foo.yml".freeze, "spec/vcr_cassettes/Solr4R_Client/requests/_json/should_get_/select_JSON.yml".freeze, "spec/vcr_cassettes/Solr4R_Client/requests/_json/should_get_/select_JSON_with_wt_string_override.yml".freeze, "spec/vcr_cassettes/Solr4R_Client/requests/_json/should_get_/select_JSON_with_wt_symbol_override.yml".freeze]
  s.homepage = "http://github.com/blackwinter/solr4r".freeze
  s.licenses = ["AGPL-3.0".freeze]
  s.post_install_message = "\nsolr4r-0.3.1 [2016-06-06]:\n\n* Added +limit+ parameter to Solr4R::Result#spellcheck_collations.\n\n".freeze
  s.rdoc_options = ["--title".freeze, "solr4r Application documentation (v0.3.1)".freeze, "--charset".freeze, "UTF-8".freeze, "--line-numbers".freeze, "--all".freeze, "--main".freeze, "README".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0".freeze)
  s.rubygems_version = "2.6.4".freeze
  s.summary = "A Ruby client for Apache Solr.".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nokogiri>.freeze, ["~> 1.6"])
      s.add_runtime_dependency(%q<nuggets>.freeze, ["~> 1.5"])
      s.add_development_dependency(%q<vcr>.freeze, ["~> 3.0"])
      s.add_development_dependency(%q<webmock>.freeze, ["~> 2.1"])
      s.add_development_dependency(%q<hen>.freeze, [">= 0.8.5", "~> 0.8"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
      s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
    else
      s.add_dependency(%q<nokogiri>.freeze, ["~> 1.6"])
      s.add_dependency(%q<nuggets>.freeze, ["~> 1.5"])
      s.add_dependency(%q<vcr>.freeze, ["~> 3.0"])
      s.add_dependency(%q<webmock>.freeze, ["~> 2.1"])
      s.add_dependency(%q<hen>.freeze, [">= 0.8.5", "~> 0.8"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
      s.add_dependency(%q<rspec>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<nokogiri>.freeze, ["~> 1.6"])
    s.add_dependency(%q<nuggets>.freeze, ["~> 1.5"])
    s.add_dependency(%q<vcr>.freeze, ["~> 3.0"])
    s.add_dependency(%q<webmock>.freeze, ["~> 2.1"])
    s.add_dependency(%q<hen>.freeze, [">= 0.8.5", "~> 0.8"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, [">= 0"])
  end
end
