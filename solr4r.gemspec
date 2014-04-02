# -*- encoding: utf-8 -*-
# stub: solr4r 0.0.1 ruby lib

Gem::Specification.new do |s|
  s.name = "solr4r"
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Jens Wille"]
  s.date = "2014-04-02"
  s.description = "A Ruby client for Apache Solr"
  s.email = "jens.wille@gmail.com"
  s.extra_rdoc_files = ["README", "COPYING", "ChangeLog"]
  s.files = ["COPYING", "ChangeLog", "README", "Rakefile", "lib/solr4r.rb", "lib/solr4r/builder.rb", "lib/solr4r/client.rb", "lib/solr4r/request.rb", "lib/solr4r/response.rb", "lib/solr4r/version.rb", "spec/solr4r/builder_spec.rb", "spec/spec_helper.rb"]
  s.licenses = ["AGPL-3.0"]
  s.post_install_message = "\nsolr4r-0.0.1 [2014-03-28]:\n\n* Birthday :-)\n\n"
  s.rdoc_options = ["--title", "solr4r Application documentation (v0.0.1)", "--charset", "UTF-8", "--line-numbers", "--all", "--main", "README"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3")
  s.rubygems_version = "2.2.2"
  s.summary = "A Ruby client for Apache Solr"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<curb>, ["> 0.8.5", "~> 0.8"])
      s.add_runtime_dependency(%q<nokogiri>, ["~> 1.6"])
    else
      s.add_dependency(%q<curb>, ["> 0.8.5", "~> 0.8"])
      s.add_dependency(%q<nokogiri>, ["~> 1.6"])
    end
  else
    s.add_dependency(%q<curb>, ["> 0.8.5", "~> 0.8"])
    s.add_dependency(%q<nokogiri>, ["~> 1.6"])
  end
end
