# Pre-requisites for running Observer in development mode
* [Git](https://git-scm.com/) - version control system. Allows to [clone](https://git-scm.com/docs/git-clone) the project source code.
* [RVM](https://rvm.io/) - Ruby Version Manager. Makes [Ruby](https://www.ruby-lang.org/en/) installation easier.
* [Ruby](https://www.ruby-lang.org/en/) - programming language of choice for the project.
* [Bundler](https://bundler.io/) - manages [Ruby Gems](https://rubygems.org/gems) for the project.
* [Rubocop](https://github.com/rubocop-hq/rubocop) - a code analyzer (linter) that reviews the source code.
* [YARD](https://yardoc.org/) - documentation tool that generates a web resource with detailed explanation about source code.
* [NodeJS](https://nodejs.org/en/) - provides Javascript runtime, which is mandatory for of the Gems in the project.
* [Redis](https://redis.io/) - in-memory data structure store. It's used for caching.

**Note!** Linux is the preferrable platform for running Observer in development mode. Installation steps to follow relate to:

* [Ubuntu](https://www.ubuntu.com/download/desktop) - open source Linux based OS with GUI.
* [Bash on Ubuntu for Windows 10](https://www.windowscentral.com/how-install-bash-shell-command-line-windows-10) - provides Ubuntu shell with most of Linux commands on Windows 10.

**Note!** Before installing new program, you are advised to run:

`sudo apt-get update`
`sudo apt-get upgrade`

**Note!** At the end of each installation we test if it is successfull by getting the version of the freshly installed program.

## Git installation
* `sudo apt-get install git`
* `git --version`

## RVM installation
* `sudo apt-get install software-properties-common`
* `sudo apt-add-repository -y ppa:rael-gc/rvm`
* `sudo apt-get update`
* `sudo apt-get install rvm`

Restart the computer and open a terminal. Run:

`rvm --version`

## Ruby installation
* `rvm install 2.5.3`
* `ruby --version`

An additional test is running:

`gem list`

It should output a short list of [Ruby Gems](https://rubygems.org/gems) available by default.

## Bundler installation
* `gem install bundler`
* `bundler --version`

## NodeJS installation
Install (NVM)[https://github.com/creationix/nvm/releases] first:

* `curl https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash`
* `nvm --version`

Install NodeJS itself:

* `nvm install 10.15.3`
* `node --version`

## Gem management
So far, we have installed [Ruby Gems](https://rubygems.org/gems) that are common to any project based on Ruby version 2.5.3.
Now is the moment to create [Ruby Gemset](https://rvm.io/gemsets/basics) for our project.
We will later populate it with [Ruby Gems](https://rubygems.org/gems) relevant for Observer only.
The fundamental Gem is [Rails](https://rubygems.org/gems/rails/versions/5.0.0), a.k.a Ruby on Rails. Hence, the name for our gemset is going to be *rails-5.2.0*. Run:

* `rvm gemset create rails-5.2.0`
* `rvm gemset list`

It should output a list of [Ruby Gemsets](https://rvm.io/gemsets/basics) containing an item with the name *rails-5.2.0*.

## Redis installation
* `sudo apt-get install build-essential`
* `sudo apt-get install tcl8.5`
* `wget http://download.redis.io/releases/redis-stable.tar.gz`
* `tar xzf redis-stable.tar.gz`
* `cd redis-stable`
* `make`
* `make test`
* `sudo cp src/redis-server /usr/local/bin/`
* `sudo cp src/redis-cli /usr/local/bin/`
* `redis-server`

Open a new terminal and run:
* `redis-cli`
* `PING`

You should get *PONG*.

## Gem installation
Go to the root directory of the project(it contains *.ruby-gemset*, *.ruby-version*). Run:

* `bundle install --without production`

# Launch Observer on the local machine(development mode)
Go to the root directory of the project(it contains the directory *config*).
Start the following processes, whether in the background or with a dedicated terminal for each:

* `redis-server`
* `sidekiq -C config/sidekiq_development.yml`
* `rails server --environment=development`

The application is ready at *http://localhost:3000*.

**Note!** In case you are starting the application for the first time, you might need to create a database:
* `rails db:migrate`

# Backend API for the intelligence reporting
## ICMP Flood attack
Send a POST request to the `https://<observer-domain>/backend_api/dos_icmp_intelligence` with the JSON object in the body.
The JSON object must be of the following format:
`{"ip": "<number>", "incoming_req_count": <number>}`

## SQL Injection attack
Send a POST request to the `https://<observer-domain>/backend_api/sql_injection_intelligence` with the JSON object in the body.
The JSON object must be of the following format:
`{"ip": "<number>", "uris": ["<uri_1>","<uri_n>"]}`

# Launch detailed documentation
* `yard doc`
* Copy exact location of *./doc/_index.html* and open it in your browser.

# Tests
Go to root directory of the project(it contains the directory *spec*).

## Algorithms module
`rspec spec/features/algorithms/*.spec.rb`
## Analysis module
`rspec spec/features/analysis_department/*.spec.rb`
## Archive module
`rspec spec/features/archive_department/*.spec.rb`
## Intelligence module
`rspec spec/features/intelligence_department/*.spec.rb`
## ThinkTank module
`rspec spec/features/think_tank_department/*.spec.rb`
## ICMP DoS flood positive true and negative true
`rspec spec/features/workers/icmp_cyber_report_producer.spec.rb`
## SQL Injection positive true and negative true
`rspec spec/features/workers/sql_injection_cyber_report_producer.spec.rb`

# Review (lint) the code
Go to the root directory of the project(it contains *.rubocop.yml*) and run: 

`rubocop -c .rubocop.yml --rails`

# Install FieldAgent on the FriendlyResource
* Download the file `./lib/field_agent/field_agent.py` into the directory with `.pcap` file on the FriendlyResource.
  The `.pcap` file is to contain the network in the FriendlyResource.


# Pre-requisites for the deployment to Heroku
* [Heroku CLI](https://git-scm.com/) - a tool for managing the applications hosted on [Heroku](https://devcenter.heroku.com/) in the terminal.

## Heroku CLI installation
* `cd ~`
* `curl https://cli-assets.heroku.com/install.sh | sh`

# Deploy the application to the Heroku
* `heroku login`
* `heroku create`
* `heroku addons:create heroku-redis:hobby-dev`
* `git push heroku master`
* `heroku run rake db:migrate`
* `heroku ps:scale sidekiq=1`

## Tips for resetting the database
* `heroku pg:reset -c=<APP_NAME>`
* `heroku run rake db:migrate`

## Additional tips for the Heroku CLI
* `heroku restart` - restarts the application.
* `heroku apps:destroy` - removes the application.
* `heroku ps` - list the active processes.
* `heroku domains` - list web addresses of the apps.

The application is ready! It will be available at the url that you can acquire with `heroku apps`.

# Known issues
  1. Steps for deployment to Heroku.
