require 'json'
require 'shellwords'

namespace :pm2 do
  desc 'Replace $CAP_CURRENT_PATH in the process file'
  task :modify_process_file do
    on roles fetch(:pm2_roles) do
      execute "sed -i 's/$CAP_CURRENT_PATH/#{current_path.to_s.shellescape.gsub("/", "\\/")}/' #{release_path}/#{fetch(:pm2_process_file)}"
    end
  end

  desc 'Start or gracefully reload app'
  task :start_or_graceful_reload do
    on roles fetch(:pm2_roles) do
      within deploy_path do
        with fetch(:pm2_env_variables) do
          run_task :pm2, :startOrGracefulReload, "current/#{fetch(:pm2_process_file)}", "#{fetch(:pm2_start_params)}"
        end
      end
    end
  end

  task :restart => :start_or_graceful_reload

  desc 'List all pm2 applications'
  task :status do
    run_task :pm2, :list
  end

  desc 'Start pm2 application'
  task :start do
    run_task :pm2, :start, app_name, "#{fetch(:pm2_start_params)}"
  end

  desc 'Stop pm2 application'
  task :stop do
    run_task :pm2, :stop, app_name
  end

  desc 'Delete pm2 application'
  task :delete do
    run_task :pm2, :delete, app_name
  end

  desc 'Show pm2 application info'
  task :show do
    run_task :pm2, :show, app_name
  end

  desc 'Watch pm2 logs'
  task :logs do
    run_task :pm2, :logs, app_name
  end

  desc 'Save pm2 state so it can be loaded after restart'
  task :save do
    run_task :pm2, :save
  end

  desc 'Install pm2 via npm on the remote host'
  task :setup do
    run_task :npm, :install,  'pm2 -g'
  end

  def app_name
    # stops rake from looking for tasks named after the arguments
    ARGV.each { |a| task a.to_sym do ; end }
    ARGV[2].to_s unless ARGV[2].nil?
  end

  def run_task(*args)
    on roles fetch(:pm2_roles) do
      within deploy_path do
        with fetch(:pm2_env_variables) do
          execute *args
        end
      end
    end
  end
end

namespace :load do
  task :defaults do
    set :pm2_process_file, 'ecosystem.config.js'
    set :pm2_start_params, ''
    set :pm2_roles, :all
    set :pm2_env_variables, {}
  end
end

after 'deploy:updated', 'pm2:modify_process_file'
after 'deploy:published', 'pm2:restart' # current symlink has changed after this task
