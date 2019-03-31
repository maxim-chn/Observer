# Pre-requisites for running Observer in development mode
  * [Git](https://git-scm.com/) - version control system. Allows to [clone](https://git-scm.com/docs/git-clone) the project source code.
  * [RVM](https://rvm.io/) - Ruby Version Manager. Makes [Ruby](https://www.ruby-lang.org/en/) installation easier.
  * [Ruby](https://www.ruby-lang.org/en/) - programming language of choice for the project.
  * [Bundler](https://bundler.io/) - manages [Ruby Gems](https://rubygems.org/gems) for the project.
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
  * Restart computer and open a terminal.
  * `rvm --version`
## Ruby installation
  * `rvm install 2.5.3`
  * `ruby --version`
An additional test is running:
  * `gem list`
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
  * Open new terminal and run:
    - `redis-cli`
    - `PING`
      You should get *PONG*
## Gem installation
Go to the root directory of the project(it contains *.ruby-gemset*, *.ruby-version*). Run:
  * `bundle install --without production`
# Launch Observer on local machine(development mode)
Go to the root directory of the project(it contains the directory *config*).
Start the following processes, whether in the background or with a dedicated terminal for each:
  * `redis-server`
  * `sidekiq -C config/sidekiq_development`
  * `rails server --environment=development`
The application is ready at *http://localhost:3000*.
# Launch detailed documentation
  **to be completed**
# Tests
Go to root directory of the project(it contains the directory *spec*).
## Regression tests
  **to be completed**
## Unit tests
### Algorithms module
  * `rspec spec/features/algorithms/*.spec.rb`
# Known issues
  1. Positive true test generates confidence band upper value lower than minimal amount of requests.
  2. Sniffer is not affected by "continue_analysis", based on type of analysis.
  3. There is no demo friendly resource with a season of data for holt winters forecasting algorithm.
  4. Provide regression tests.
  5. README lacks steps for deploying the project to Heroku.
  6. Detailed documentation.
  7. Refactor files.
# Refactored files
  - app
    - controllers
    - departments
    - helpers
    - models
  - lib
    - api.rb
    - services
      - icmp_flood.rb
      - validation.rb
