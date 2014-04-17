# -*- encoding: utf-8 -*-
# stub: solr4r 0.0.2 ruby lib

Gem::Specification.new do |s|
  s.name = "solr4r"
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Jens Wille"]
  s.date = "2014-04-17"
  s.description = "Access the Apache Solr search server from Ruby."
  s.email = "jens.wille@gmail.com"
  s.extra_rdoc_files = ["README", "COPYING", "ChangeLog"]
  s.files = ["COPYING", "ChangeLog", "README", "Rakefile", "TODO", "lib/solr4r.rb", "lib/solr4r/builder.rb", "lib/solr4r/client.rb", "lib/solr4r/request.rb", "lib/solr4r/request_extension.rb", "lib/solr4r/response.rb", "lib/solr4r/uri_extension.rb", "lib/solr4r/version.rb", "spec/solr4r/builder_spec.rb", "spec/spec_helper.rb"]
  s.homepage = "http://github.com/blackwinter/solr4r"
  s.licenses = ["AGPL-3.0"]
  s.post_install_message = "\nsolr4r-0.0.2 [2014-04-17]:\n\n* Refactored Solr4R::Request away from curb.\n* Refactored Solr4R::Response away from ostruct.\n\n"
  s.rdoc_options = ["--title", "solr4r Application documentation (v0.0.2)", "--charset", "UTF-8", "--line-numbers", "--all", "--main", "README"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3")
  s.rubygems_version = "2.2.2"
  s.summary = "A Ruby client for Apache Solr."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nokogiri>, ["~> 1.6"])
      s.add_development_dependency(%q<hen>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
    else
      s.add_dependency(%q<nokogiri>, ["~> 1.6"])
      s.add_dependency(%q<hen>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
    end
  else
    s.add_dependency(%q<nokogiri>, ["~> 1.6"])
    s.add_dependency(%q<hen>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
  end
end
