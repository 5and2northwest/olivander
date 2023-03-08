require_relative 'lib/olivander/version'

Gem::Specification.new do |spec|
  spec.name        = 'five-two-nw-olivander'
  spec.version     = Olivander::VERSION
  spec.authors     = ['Eric Dennis']
  spec.email       = ['devops@5and2northwest.com']
  spec.homepage    = 'https://rubygems.org/gems/olivander'
  spec.summary     = 'Summary of Olivander.'
  spec.description = 'Description of Olivander.'
  spec.license     = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri']     = spec.homepage
  spec.metadata['source_code_uri']  = 'https://github.com/5and2northwest/olivander'
  spec.metadata['changelog_uri']    = 'https://github.com/5and2northwest/olivander/blob/main/CHANGELOG.md'
  spec.metadata['bug_tracker_uri']  = 'https://github.com/5and2northwest/olivander/issues'
  spec.metadata['wiki_uri']         = 'https://github.com/5and2northwest/olivander/wiki'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md', 'CHANGELOG.md']
  end

  spec.add_dependency 'chartkick'
  spec.add_dependency 'effective_datatables'
  spec.add_dependency 'effective_resources'
  spec.add_dependency 'haml-rails', '~> 2.0'
  spec.add_dependency 'rails', '>= 7.0.4.2'
end
