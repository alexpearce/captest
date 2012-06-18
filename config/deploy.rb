# With help from:
# http://pemberthy.blogspot.co.uk/2009/02/deploying-sinatra-applications-with.html
# https://github.com/rubenfonseca/sinatra-capistrano-workshop
# http://henriksjokvist.net/archive/2012/2/deploying-with-rbenv-and-capistrano/
# http://norbyit.se/blog/2011/01/code-deployment/

require "bundler/capistrano"
set :bundle_flags, "--deployment --quiet"

set :default_environment, {
  "PATH" => "$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
}

set :application, "captest"
set :user, "deploy"
set :use_sudo, true

# Required for sudo password prompt
default_run_options[:pty] = true

# Allows passing on our local public keys
ssh_options[:forward_agent] = true

set :scm, :git
set :repository,  "git@github.com:alexpearce/captest.git"

set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache

role :app, "31.193.143.153"
role :web, "31.193.143.153"

after "deploy:cold" do
  deploy.symlink_config
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

  desc "Link the server config to nginx."
  task :symlink_config, roles: :app do
    run "#{sudo} ln -nfs #{deploy_to}/current/config/nginx.server /etc/nginx/sites_enabled/#{application}"
  end
end