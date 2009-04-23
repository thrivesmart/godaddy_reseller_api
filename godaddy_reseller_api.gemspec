# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{godaddy_reseller_api}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["ThriveSmart, LLC"]
  s.date = %q{2009-04-23}
  s.description = %q{Easily use the GoDaddy Reseller API in your Ruby projects.}
  s.email = %q{developers@thrivesmart.com}
  s.extra_rdoc_files = ["README.textile", "LICENSE"]
  s.files = ["LICENSE", "README.textile", "Rakefile", "lib/authentication.rb", "lib/certification.rb", "lib/connection.rb", "lib/dns.rb", "lib/domains.rb", "lib/godaddy_reseller.rb", "lib/product_table.rb", "lib/util.rb", "lib/wapi.rb", "spec/dns_spec.rb", "spec/domains_spec.rb", "spec/godaddy_reseller_spec.rb", "spec/product_table_spec.rb", "spec/spec_helper.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/moorage/godaddy_reseller_api}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{godaddy_reseller_api}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Easily use the GoDaddy Reseller API in your Ruby projects.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
