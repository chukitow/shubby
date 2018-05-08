RAILS_VERSION   = '5.1.5'
RUBY_VERSION    = '2.4.0'
$install_devise = false

if __FILE__ =~ %r{\Ahttps?://}
  source_paths.unshift(tempdir = Dir.mktmpdir("shubby-"))
  at_exit { FileUtils.remove_entry(tempdir) }
  git :clone => [
    "--quiet",
    "https://github.com/chukitow/shubby.git",
    tempdir
    ].join(" ")
else
  source_paths.unshift(File.dirname(__FILE__))
end

remove_file "Gemfile"
template './templates/Gemfile.erb', 'Gemfile'
template './templates/ruby-version.tt', '.ruby-version'
template './templates/ruby-gemset.tt', '.ruby-gemset', app_name

inside 'config' do
  remove_file 'database.yml'
end

template './templates/config/database.erb', 'database.yml', app_name

if yes?("Would you like to install Devise? Y/N")
  gem "devise"
  $install_devise = true
end

after_bundle do
  remove_dir "test"
  generate "rspec:install"

  if $install_devise
    generate "devise:install"
  end

  remove_file 'spec/rails_helper.rb'
  template 'templates/spec/rails_helper.erb', 'spec/rails_helper.rb'
end
