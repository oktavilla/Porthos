namespace :porthos do
  
  desc "Copy all static porthos files to "
  task :copy_dependencys do
    printf "Warning this will overwrite any changes done. Continue? [y/n]"
    if STDIN.gets.chomp == 'y'
      ['config/initializers', 
       'config/locales',
       'config/ultrasphinx',
       'vendor/plugins'].each { |dir| find_and_copy_files(dir) }
    end
  end
  
  desc "Symlink porthos public files"
  task :symlink_public_dirs do
    mkdir File.join(app_path, 'public/graphics') unless File.exists?(File.join(app_path, 'public/graphics'))
    ['public/graphics/porthos', 'public/javascripts/porthos', 'public/stylesheets/porthos', 'public/swf'].each do |dir|
      origin, destination = File.join(plugin_path, dir), File.join(app_path, dir)
      unless File.exists?(destination)
        system("ln -s #{origin} #{destination}")
        printf "Linked #{destination} to #{origin}\n"
      else
        printf "#{destination} already linked\n"
      end
    end
  end
  
  
  desc "Update Porthos"
  task :update do
    printf "Update porthos plugin with piston? [y/n]"
    if STDIN.gets.chomp == 'y'
      system('piston update vendor/plugins/porthos')
    end
    printf "Do you want to overwrite all public files in the porthos directorys (stylesheets / javascripts / graphics) [y/n] "
    if STDIN.gets.chomp == 'y'
      Rake::Task["porthos:copy_dependencys"].invoke
    end
  end
  
  desc "Install porthos"
  task :install do
    
    if File.exists?("#{app_path}/assets")
      printf "Porthos looks to be installed, sure you want to continue? [y/n] "
      exit unless STDIN.gets.chomp == 'y'
    else
      mkdir File.join(app_path, 'assets')
    end
    
    Rake::Task["porthos:copy_dependencys"].invoke      
    Rake::Task["porthos:symlink_public_dirs"].invoke      
    
    ['config/asset_packages.yml'].each do |file|
      cp File.join(plugin_path, file), File.join(app_path, file) unless File.exists?(File.join(app_path, file))
    end
    
    printf "Do you want to patch routes.rb and environment.rb to add porthos routes and inclusion of desert? [y/n] "
    if STDIN.gets.chomp == 'y'
      gsub_file 'config/routes.rb', /(#{Regexp.escape('ActionController::Routing::Routes.draw do |map|')})/mi do |match|
        "#{match}\n  map.routes_from_plugin :porthos\n"
      end
      gsub_file 'config/environment.rb', /(#{Regexp.escape('require File.join(File.dirname(__FILE__), \'boot\')')})/mi do |match|
        "#{match}\nrequire 'desert'\nSESSION_KEY = '_porthos_session'"
      end
    end
    
    printf "Install plugins? [y/n] "
    if STDIN.gets.chomp == 'y'
      system('svn export http://dev.rubyonrails.org/svn/rails/plugins/acts_as_list vendor/plugins/acts_as_list')
      system('svn export http://dev.rubyonrails.org/svn/rails/plugins/acts_as_tree vendor/plugins/acts_as_tree')
      system('svn export http://liquid-markup.googlecode.com/svn/trunk vendor/plugins/liquid')
      system('svn export http://sbecker.net/shared/plugins/asset_packager vendor/plugins/asset_packager')
      system('svn export http://repo.pragprog.com/svn/Public/plugins/annotate_models vendor/plugins/annotate_models')
      system('svn export http://labnotes.org/svn/public/ruby/rails_plugins/assert_select vendor/plugins/assert_select')
      system('svn export svn://rubyforge.org/var/svn/fauna/ultrasphinx/trunk vendor/plugins/ultrasphinx')
      system('svn export http://ruby-imagespec.googlecode.com/svn/trunk/ vendor/plugins/imagespec')
      system('svn export http://code.macournoyer.com/svn/plugins/defensio/ vendor/plugins/defensio')
      system('script/plugin install git://github.com/giraffesoft/ultrasphinx.git')
      printf "\n\n Also install will_paginate gem (sudo gem install mislavs-will_paginate)\n"
    end
    
    printf "Run ultrasphinx configuration task? [y/n] "
    if STDIN.gets.chomp == 'y'
      Rake::Task["ultrasphinx:configure"].invoke 
    end
    
    printf "Run porthos migrations? [y/n] "
    if STDIN.gets.chomp == 'y'
      ENV['SCHEMA'] = File.join(plugin_path, 'db/schema.rb')
      Rake::Task["db:schema:load"].invoke      
      User.create(:admin => true, :login => 'admin', :password => 'password', :password_confirmation => 'password', :first_name => 'Admin', :last_name => 'Admin', :email => 'admin@example.com')
    end
  end
  
  desc "Load default db"
  task :install_database do
    plugin_path = "#{File.dirname(__FILE__)}/../.."
    ENV['SCHEMA'] = File.join(plugin_path, 'db/schema.rb')
    Rake::Task["db:schema:load"].invoke      
    User.create(:admin => true, :login => 'admin', :password => 'password', :password_confirmation => 'password', :first_name => 'Admin', :last_name => 'Admin', :email => 'admin@example.com')
  end
  
  desc "Reset MemCache node cache"
  task (:reset_node_cache => :environment) do
    require "porthos/routing.rb"
    memcache = Porthos::Routing::MemCacheStore.new
    memcache.store({})
  end
end

private

  def gsub_file(destination, regexp, *args, &block)
    content = File.read(destination).gsub(regexp, *args, &block)
    File.open(destination, 'wb') { |file| file.write(content) }
  end

  def plugin_path
    "#{File.dirname(__FILE__)}/../.."
  end

  def app_path
    RAILS_ROOT
  end

  def find_and_copy_files(dir)
    mkdir File.join(app_path, dir) unless File.exists? File.join(app_path, dir)
    Dir.foreach(File.join(plugin_path, dir)) do |entry|
      origin      = File.join(plugin_path, dir, entry)
      destination = File.join(app_path, dir, entry)
      unless File.basename(entry)[0,1] == '.'
        if File.file? origin
          system("cp -f #{origin} #{destination}") # overwrite any existing files
        elsif File.directory? origin
          mkdir destination unless File.exists? destination
          find_and_copy_files File.join(dir, entry)
        end
      end
    end
  end