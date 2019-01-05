# ##################################################
# Load enums and classes shared by departments.
# ##################################################
require("#{Rails.root}/app/departments/demo/shared/analysis_query.rb")
require("#{Rails.root}/app/departments/demo/shared/analysis_type.rb")
require("#{Rails.root}/app/departments/demo/shared/intelligence_format.rb")
require("#{Rails.root}/app/departments/demo/shared/intelligence_query.rb")
# ##################################################
# Load lib.
# ##################################################
require("#{Rails.root}/lib/algorithms/holt_winters_forecasting/api.rb")
# ##################################################
# Load workers.
# ##################################################
require("#{Rails.root}/app/workers/demo/analysis/dos/icmp_interpretation_data_producer.rb")
require("#{Rails.root}/app/workers/demo/analysis/dos/redis_channels.rb")
require("#{Rails.root}/app/workers/demo/analysis/dos/stop_icmp_interpretation_data_producer.rb")
require("#{Rails.root}/app/workers/demo/intelligence/add_collection_format.rb")
require("#{Rails.root}/app/workers/demo/intelligence/remove_collection_format.rb")
# ##################################################
# Load departments.
# ##################################################
require("#{Rails.root}/app/departments/demo/analysis/analysis_api.rb")
require("#{Rails.root}/app/departments/demo/archive/archive_api.rb")
require("#{Rails.root}/app/departments/demo/intelligence/intelligence_api.rb")
require("#{Rails.root}/app/departments/demo/think_tank/think_tank_api.rb")
# ##################################################
# First time call for Singletons.
# ##################################################
Departments::Demo::Archive::ArchiveApi.instance()
Departments::Demo::ThinkTank::ThinkTankApi.instance()
Algorithms::HoltWintersForecasting::Api.instance()