# With help from:
# http://pemberthy.blogspot.co.uk/2009/02/deploying-sinatra-applications-with.html
# https://github.com/rubenfonseca/sinatra-capistrano-workshop
# http://henriksjokvist.net/archive/2012/2/deploying-with-rbenv-and-capistrano/

require "bundler/capistrano"
set :bundle_flags, "--deployment --quiet"

set :default_environment, {
  "PATH" => "$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
}

set :application, "captest"
set :user, "deploy"
set :use_sudo, false

ssh_options[:forward_agent] = true

set :scm, :git
set :repository,  "git@github.com:alexpearce/captest.git"

set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache

role :app, "31.193.143.153"
role :web, "31.193.143.153"


# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do
  end

  task :stop do
  end

  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  # This will make sure that Capistrano doesn't try to run rake:migrate (this is not a Rails project!)
  task :cold do
    deploy.update
    deploy.start
  end
end