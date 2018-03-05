nodejs [pm2](https://github.com/Unitech/pm2) 2.x support for Capistrano 3.x

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capistrano', '~> 3.1.0'
gem 'capistrano-pm2', :git => 'https://github.com/codevate/capistrano-pm2.git'
```

And then execute:

    $ bundle

Require in `Capfile` to use the default task:

```ruby
require 'capistrano/pm2'
```

Some tasks will automatically run as part of Capistrano's default deploy, here's how they fit into the [flow](http://capistranorb.com/documentation/getting-started/flow/):

```bash
deploy
  deploy:updated
    [after]
      pm2:modify_process_file
  deploy:published
    [after]
      pm2:restart
```

## Usage

This gem follows the conventions outlined in ["Capistrano like deployments"](http://pm2.keymetrics.io/docs/tutorials/capistrano-like-deployments).

The application process(es) to manage must be declared by a [process file](http://pm2.keymetrics.io/docs/usage/application-declaration). You can generate a sample process file with the following command:

```bash
pm2 ecosystem
```

### Process file

Each application in the process file **must** have a `cwd` value that is an absolute path to the current deploy symlink, with the `script` path relative to it.
This is so that PM2 always restarts the most recently deployed script. As a convenience, rather than hardcoding this path, use the value `$CAP_CURRENT_PATH`.

Here's a basic example:

```yml
# process.yml
apps:
  - name: myapp
    script: ./dist/index.js
    cwd: $CAP_CURRENT_PATH
```

```ruby
# deploy.rb
set :pm2_process_file, 'process.yml'
set :deploy_to, '/home/ubuntu/myapp'
```

On each deploy, the gem will update the `cwd` option to the correct path:

```yml
# /home/ubuntu/myapp/releases/20180305210446/process.yml
apps:
  - name: myapp
    script: ./dist/index.js
    cwd: /home/ubuntu/myapp/current
```

```bash
# pm2 show myapp
│ name              │ myapp                                              │
│ restarts          │ 0                                                  │
│ uptime            │ 0                                                  │
│ script path       │ /home/ubuntu/myapp/current/dist/index.js           │

```

Any changes to the process file outside of environment variables (see below) will require the relevant app(s) to be deleted before the next deploy to take effect:

```bash
cap <stage> pm2:delete myapp
```

### Environment variables

By default, [PM2 doesn’t change process environment](http://pm2.keymetrics.io/docs/usage/environment/#while-restarting-reloading-a-process) while restarting. If you make changes to `env` in your process file, you'll need to add `--update-env` as a start param:

```ruby
# deploy.rb
set :pm2_start_params, '--update-env'
```

### Available tasks

```ruby
cap pm2:delete <app_name>          # Delete pm2 application
cap pm2:logs [<app_name>]          # Watch all pm2 logs (or provide an app name)
cap pm2:restart <app_name>         # Restart app gracefully
cap pm2:setup                      # Install pm2 via npm on the remote host
cap pm2:show <app_name>            # Show pm2 application info
cap pm2:start <app_name>           # Start pm2 application
cap pm2:status                     # List all pm2 applications
cap pm2:stop <app_name>            # Stop pm2 application
cap pm2:save                       # Save pm2 state so it can be loaded after restart
```

### Configurable options

```ruby
set :pm2_process_file, 'ecosystem.config.js'      # the process file
set :pm2_roles, :all                              # server roles where pm2 runs on
set :pm2_env_variables, {}                        # default: env vars for pm2
set :pm2_start_params, ''                         # pm2 start params see http://pm2.keymetrics.io/docs/usage/quick-start/#cheat-sheet
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
