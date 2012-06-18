# With help from:
# http://pemberthy.blogspot.co.uk/2009/02/deploying-sinatra-applications-with.html
# https://github.com/rubenfonseca/sinatra-capistrano-workshop
# http://henriksjokvist.net/archive/2012/2/deploying-with-rbenv-and-capistrano/
# http://norbyit.se/blog/2011/01/code-deployment/

# Use Bundler
require "bundler/capistrano"
set :bundle_flags, "--deployment --quiet"

# Load rbenv
set :default_environment, {
  "PATH" => "$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
}

# Application name
set :application, "captest"
# User to deploy as
set :user, "deploy"
# No need for sudo. Can use #{sudo} if we explicitly need it
set :use_sudo, false

# Required for sudo password prompt
default_run_options[:pty] = true

# Allows passing on our local public keys
ssh_options[:forward_agent] = true

# Use git, set the repo
set :scm, :git
set :repository,  "git@github.com:alexpearce/captest.git"

set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache

# Where is the app server?
role :app, "31.193.143.153"

# After an initial (cold) deploy, symlink the app and restart nginx
after "deploy:cold" do
  admin.symlink_config
  admin.nginx_restart
end


# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  desc "Not starting as we're running passenger."
  task :start do
  end

  desc "Not stopping as we're running passenger."
  task :stop do
  end

  desc "Restart the app."
  task :restart, roles: :app, except: { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  # This will make sure that Capistrano doesn't try to run rake:migrate (this is not a Rails project!)
  task :cold do
    deploy.update
    deploy.start
  end
end

namespace :admin do
    desc "Link the server config to nginx."
  task :symlink_config, roles: :app do
    run "#{sudo} ln -nfs #{deploy_to}/current/config/nginx.server /etc/nginx/sites_enabled/#{application}"
  end

  desc "Unlink the server config."
  task :unlink_config, roles: :app do
    run "#{sudo} rm /etc/nginx/sites_enabled/#{application}"
  end

  desc "Restart nginx."
  task :nginx_restart, roles: :app do
    run "#{sudo} /etc/init.d/nginx restart"
  end
end