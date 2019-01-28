# frozen_string_literal: true

require(Rails.root('app', 'workers', 'demo', 'worker_with_redis.rb'))
require(Rails.root('app', 'workers', 'demo', 'analysis', 'dos', 'holt_winters_forecasting_worker.rb'))
require(Rails.root('app', 'workers', 'demo', 'analysis', 'dos', 'icmp', 'cyber_report_producer.rb'))
require(Rails.root('app', 'workers', 'demo', 'intelligence', 'add_collection_format.rb'))
require(Rails.root('app', 'workers', 'demo', 'intelligence', 'remove_collection_format.rb'))
