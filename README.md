# Chap

[![Build History][2]][1]

[1]: http://travis-ci.org/tongueroo/chap
[2]: https://secure.travis-ci.org/tongueroo/chap.png?branch=master

chef + capistrano = chap: deploy your app with either chef or capistrano.  This was written to solve the issue between having 2 deployment systems that are very similar but not exactly the same.  With chap you can deploy to a single server by running one command: 

<pre>
$ chap deploy
</pre>

The same command is called whether you're using chef or capistrano for deployment.  The chap deploy command does the heavy lifting and manages the deploy instead of capistrano or chef.

## Requirements

<pre>
$ gem install chap
</pre>

## Setup

Chap requires 3 configuration files: chap.yml, chap.json and node.json.

* chap.json: contains capistrano-like configuration settings.
* node.json: is intended to be the same file that chef solo uses and contains instance specific information, like node[:instance_role].
* chap.yml: The paths of the chap.json and node.json are configured in this file.

Here are examples of the starter setup files that you can generate via: 

<pre>
$ chap setup -o /etc/chef
</pre>

<pre>
$ cat /etc/chef/chap.yml
chap: /etc/chef/chap.json
node: /etc/chef/node.json
$ cat /etc/chef/chap.json
{
  "repo": "git@github.com:tongueroo/chapdemo.git",
  "branch": "master",
  "application": "chapdemo",
  "deploy_to": "/data/chapdemo",
  "strategy": "checkout",
  "keep": 5,
  "user": "deploy",
  "group": "deploy"
}
$ cat /etc/chef/node.json
{
  "environment": "staging",
  "application": "chapdemo",
  "instance_role": "app"
}
</pre>

## Usage

The chap command is meant to be executed on the server which you want to deploy the code.  

### Deploy sequence

The deploy sequence is based on the sequence from the capistrano and chef deploy resource provider.

1. Download code to [deploy_to]/releases/[timestamp]
2. Run chap/deploy hook
3. Symlink [deploy_to]/releases/[timestamp] to [deploy_to]/current
4. Run chap/restart hook
5. Clean up old releases

On the server:

<pre>
$ chap deploy
</pre>

From capistrano, on local or deploy box:

<pre>
$ cap deploy # cap recipe calls "chap deploy"
</pre>

Example capistrano deploy

```ruby
namespace :deploy do
  task :default do
    run "chap deploy"
  end
```

Chef Chap LWRP:

<pre>
# chef LWRP creates chap.yml and chap.json setup files and calls "chap deploy"
chap_deploy "chapdemo" do
  repo "git@github.com:tongueroo/chapdemo.git"
  revision "master"
end
</pre>

Chap loads up information from node.json because it needs the information for hooks, which tend to work differently for different server roles.  For example, the chap/restart hook below will run "touch tmp/restart.txt" for an app role and will run "rvmsudo bluepill restart resque" for a resque role.  Example:

<pre>
$ cat chap/restart
#!/usr/bin/env ruby
if node[:instance_role] == 'app'
  run "cd #{current_path} && touch tmp/restart.txt"
elsif node[:instance_role] == 'resque'
  run "rvmsudo bluepill restart resque"
end
</pre>

### Deploy Hooks

Define your deploy hooks in the chap folder of the project.  There are 2 deploy hooks.

* chap/deploy - runs after the code has been deployed but not yet symlinked
* chap/restart - runs after the code has been symlinked and app needs to be restarted

Deploy hooks get evaluated within the context of a chap deploy run and have some special variables and methods:

Special variables:

* node - contains data from /etc/chef/node.json.  Avaiable as mash.
* chap - contains data from /etc/chef/chap.json and some special variables added by chap.  Avaiable as mash.  Special variables: release_path, current_path, shared_path, cached_path, latest_release.  The special variables are also available directly as methods.

Special methods:

* run - output the command to be ran and runs command.
* log - log messages to [shared_path]/chap/chap.log.
* symlink_configs - useful as a chap/deploy hook. Symlinks any config files in [shared_path]/config/* over to [release_path]/config.
* with - used to prepend all commands within a block with another command.  A example is provided below.

with example:

<pre>
with "cd #{release_path} && RAILS_ENV=#{node[:environment]} " do
  run "rake do:something1"
  run "rake do:something2"
end
</pre>

is the same as:

<pre>
run "cd #{release_path} && RAILS_ENV=#{node[:environment]} rake do:something1"
run "cd #{release_path} && RAILS_ENV=#{node[:environment]} rake do:something2"
</pre>


### Test deploy hooks

When a chap hook fails, you might want to quicky test it on the server without having commit new code and running a full deploy.  You can edit the chap/* hooks on the spot and test them via:

<pre>
$ cap hook deploy
$ cap hook restart
</pre>

This will test the hooks on the latest timestamp release at [deploy_to]/releases/[timestamp].

### Syncing restart phase

Some apps require that all the code be available on all the servers before a restart should happen on any of the servers.  For example, if you're serving assets on the same server as your app code, you want to make sure that all the assets have been download on all servers before any of the servers start serving the new assets.  To sync the retart phase you have to break out the capistano recipe so that it calls 2 chap command:

```ruby
task :chap do
  run "chap deploy -q --stop-at-symlink"
  run "chap deploy -q --cont-at-symlink"
end
```