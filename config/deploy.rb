set :user,         "unicef"
set :application,  "unicef"
set :repository,   "http://svn.unicef.se/unicef.se/trunk"

set :mongrel_config, "" 

task :staging do

  role :web, "staging.unicef.se"
  role :app, "staging.unicef.se"
  role :db,  "staging.unicef.se", :primary => true

  ssh_options[:port] = 8888
  set :deploy_to, "/home/#{user}/staging"
  set :deploy_via, :checkout
  
  set :mongrel_config, "/etc/mongrel_cluster/unicef2.yml" 
  set :rails_env, 'staging'
  set :use_sudo, false
  
end

task :production do

  role :web, "unicef.se"
  role :app, "unicef.se"
  role :db,  "unicef.se", :primary => true

  ssh_options[:port] = 8888
  set :deploy_to, "/home/#{user}/production"
  set :rails_env, 'production'
  set :deploy_via, :checkout
  
  set :mongrel_config, "/etc/mongrel_cluster/unicef_production.yml" 

  set :use_sudo, false
  
end

task :development do

  role :web, "dev.winstondesign.se"
  role :app, "dev.winstondesign.se"
  role :db,  "dev.winstondesign.se", :primary => true

  ssh_options[:port] = 8888
  set :deploy_to, "/home/#{user}/development"
  set :rails_env, 'development'
  set :deploy_via, :checkout
  set :repository, Capistrano::CLI.ui.ask("\n*******************************\nSVN rep (default: #{self[:repository]}): ")
  set :repository, "http://svn.unicef.se/unicef.se/trunk" if self[:repository] == ''
  set :mongrel_config, "/etc/mongrel_cluster/unicef_development.yml" 

  set :use_sudo, false
  
end


namespace :deploy do

  task :after_update_code do
    copy_config_files
    relink_shared_assets_dir
    relink_shared_uploaded_graphics_dir
    relink_shared_images_dir
    relink_cache_dir
    symlink_edge
    symlink_media_dir
    Rake::Task["porthos:symlink_public_dirs"].invoke
    symlink_flash_videos
    pack_assets
  end
  
  desc "Restart mongrel"
  task :restart, :roles => :app do
    raise "Please specify mongrel_config path" if mongrel_config == ""
    sudo "mongrel_rails cluster::restart -C #{mongrel_config}"
  end
  
  desc "Start mongrel"
  task :start, :roles => :app do
    raise "Please specify mongrel_config path" if mongrel_config == ""
    sudo "mongrel_rails cluster::start -C #{mongrel_config}"
  end
  
  desc "Stop mongrel"
  task :stop, :roles => :app do
    raise "Please specify mongrel_config path" if mongrel_config == ""
    sudo "mongrel_rails cluster::stop -C #{mongrel_config}"
  end

  desc "Copy shared config files to new release"
  task :copy_config_files, :roles => :app do
    %w(database.yml mongrel_cluster.yml).each do |conf|
      run "cp #{shared_path}/system/config/#{conf} #{release_path}/config/#{conf}"
    end
  end

  desc "Relink uploaded assets dir in the release"
  task :relink_shared_assets_dir, :roles => :app do
    run "rm -rf #{release_path}/assets"
    run "mkdir -p #{shared_path}/system/assets"
    run "chmod -R 755 #{shared_path}/system/assets"
    run "ln -nfs #{shared_path}/system/assets #{release_path}/assets"
  end

  desc "Relink uploaded graphics dir in the release"
  task :relink_shared_uploaded_graphics_dir, :roles => :app do
    run "rm -rf #{release_path}/public/uploaded_graphics"
    run "mkdir -p #{shared_path}/system/uploaded_graphics"
    run "chmod -R 755 #{shared_path}/system/uploaded_graphics"
    run "ln -nfs #{shared_path}/system/uploaded_graphics #{release_path}/public/uploaded_graphics"
  end

  desc "Relink generated images dir in the release"
  task :relink_shared_images_dir, :roles => :app do
    run "rm -rf #{release_path}/public/images"
    run "mkdir -p #{shared_path}/system/images"
    run "chmod -R 755 #{shared_path}/system/images"
    run "ln -nfs #{shared_path}/system/images #{release_path}/public/images"
  end

  desc "Symlink all flashvideos"
  task :symlink_flash_videos, :roles => :app do
    run "ln -nfs #{shared_path}/system/assets/*.flv #{release_path}/public/videos/"
  end

  desc "Relink cache dir in the release"
  task :relink_cache_dir, :roles => :app do
    run "rm -rf #{release_path}/public/cache"
    run "mkdir -p #{shared_path}/system/cache"
    run "chmod -R 755 #{shared_path}/system/cache"
    run "ln -nfs #{shared_path}/system/cache #{release_path}/public/cache"
  end
  
  desc "Removes all cached files"
  task :cleanup_cache, :roles => :app do
    run "rm -R #{shared_path}/system/cache/*"
  end
  
  desc "Symlink edge rails directory to release path"
  task :symlink_edge, :roles => :app do
    run "ln -nfs #{shared_path}/system/rails #{release_path}/vendor/rails"
  end

  desc "Create symlink to old unicef site images"
  task :symlink_media_dir, :roles => :app do
    run "ln -nfs #{shared_path}/system/media #{release_path}/public/media"
  end

 desc "Create asset packages for production" 
 task :pack_assets, :roles => [:web] do
   run "cd #{release_path} && rake RAILS_ENV=#{rails_env} asset:packager:build_all"
 end
end