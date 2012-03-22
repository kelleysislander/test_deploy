require 'capistrano/ext/multistage'
set :stages, %w(beaglebone)
set :default_stage, "beaglebone"
set :application, "test_deploy"
set :user, "root"
set :use_sudo, "false"

default_run_options[:pty] = true
set :application, 'test_deploy'
set :app_uri,   'test_deploy.semaphoremobile.com'
set :deploy_to, "/var/www/vhosts/#{app_uri}"
set :gem_home, '/home/root/.rvm/gems/ruby-1.9.2-p290@test_deploy'
set :gem_path, '/home/root/.rvm/gems/ruby-1.9.2-p290:/home/deploy/.rvm/gems/ruby-1.9.2-p290@global' # got these last 2 via "gem info" on the app server's app root

set :repository, "git@github.com:kelleysislander/sample_blog.git"
set :branch, "master"
set :scm, :git

set :scm_verbose, true
set :git_enable_submodules, 1
set :keep_releases, 5
set :port, 22
set :domain, "10.0.1.160"

set :chmod755, "app config db lib public vendor script script/* public/*"
set :ssh_options, { :forward_agent => true }

role :web, domain
role :app, domain
role :db,  domain, :primary => true

namespace :deploy do
    desc "Restart Application"
    task :restart, :roles => :app do
      sudo "touch #{current_path}/tmp/restart.txt"
    end

    desc "Make symlink for database.yml" 
    task :symlink_dbyaml do
      sudo "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml" 
    end

    desc "Create empty database.yml in shared path" 
    task :create_dbyaml do
      sudo "mkdir -p #{shared_path}/config" 
      put '', "#{shared_path}/config/database.yml" 
    end

    desc "Make symlink for s3.yml" 
    task :symlink_s3yaml do
      sudo "ln -nfs #{shared_path}/config/s3.yml #{release_path}/config/s3.yml" 
    end

    desc "Create empty s3.yml in shared path" 
    task :create_s3yaml do
      sudo "mkdir -p #{shared_path}/config" 
      put '', "#{shared_path}/config/s3.yml" 
    end
    
    desc "Make symlink for restart.txt" 
    task :symlink_restart do
      sudo "ln -nfs #{shared_path}/system/restart.txt #{release_path}/tmp/restart.txt" 
      sudo "touch #{current_path}/tmp/restart.txt"
    end    
  end

  # after 'deploy:setup', 'deploy:create_dbyaml'
  # after 'deploy:update_code', 'deploy:symlink_dbyaml'
  # after 'deploy:setup', 'deploy:create_s3yaml'
  # after 'deploy:update_code', 'deploy:symlink_s3yaml'
  # after 'deploy:update_code', 'deploy:symlink_restart' 
  after 'deploy', 'deploy:cleanup'

