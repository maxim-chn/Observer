# Pre-requisites for running Observer in development mode
  * [Git](https://git-scm.com/) - version control system. Allows to [clone](https://git-scm.com/docs/git-clone) the project source code.
  * [RVM](https://rvm.io/) - Ruby Version Manager. Makes [Ruby](https://www.ruby-lang.org/en/) installation easier.
  * [Ruby](https://www.ruby-lang.org/en/) - programming language of choice for the project.
  * [Bundler](https://bundler.io/) - manages [Ruby Gems](https://rubygems.org/gems) for the project.
  * [Redis](https://redis.io/) - in-memory data structure store. It's used for caching.
**Note!** Linux is the preferrable platform for running Observer in development mode. So far, we have used following Ubuntu options:
  * [Ubuntu](https://www.ubuntu.com/download/desktop) - open source Linux based OS with GUI.
  * [Bash on Ubuntu for Windows 10](https://www.windowscentral.com/how-install-bash-shell-command-line-windows-10) - provides Ubuntu shell with most of Linux commands on Windows 10.
Following installation steps are relevant for Ubuntu.
Before installing new program, you are advised to run:
  `sudo apt-get update`
  `sudo apt-get upgrade`
## Git installation
  * `sudo apt-get install git`
  * `git --version`. If you get a version of git, it's installation has been successfull.
# Launch local instance in development mode
Local instance uses SQLITE3 database.
Command to launch rails server with connection to SQLITE3: `rails --environment=development`
# Known issues
  1. Positive true test generates confidence band upper value lower than minimal amount of requests.
  2. Sniffer is not affected by "continue_analysis", based on type of analysis.
  3. There is no demo friendly resource with a season of data for holt winters forecasting algorithm.
  4. README lacks steps for installing pre-requisites.
  5. README lacks steps for deploying the project to Heroku.
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
