# frozen_string_literal: true

require(Rails.root.join('app', 'workers', 'worker_with_redis.rb'))
require(Rails.root.join('app', 'workers', 'analysis', 'dos', 'holt_winters_forecasting_worker.rb'))
require(Rails.root.join('app', 'workers', 'analysis', 'dos', 'icmp', 'cyber_report_producer.rb'))
require(Rails.root.join('app', 'workers', 'intelligence', 'add_collection_format.rb'))
require(Rails.root.join('app', 'workers', 'intelligence', 'remove_collection_format.rb'))
