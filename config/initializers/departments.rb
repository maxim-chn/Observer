# ##################################################
# Load enums and classes shared by departments.
# ##################################################
require("#{Rails.root}/app/departments/demo/shared/analysis_query.rb")
require("#{Rails.root}/app/departments/demo/shared/analysis_type.rb")
require("#{Rails.root}/app/departments/demo/shared/intelligence_format.rb")
require("#{Rails.root}/app/departments/demo/shared/intelligence_query.rb")
# ##################################################
# Load workers.
# ##################################################
require("#{Rails.root}/app/workers/demo/analysis/interpretation_data_producer.rb")
require("#{Rails.root}/app/workers/demo/analysis/stop_interpretation_data_producer.rb")
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
# Calling Archive and ThinkTank is enough.
# ##################################################
Departments::Demo::Archive::ArchiveApi.instance()
Departments::Demo::ThinkTank::ThinkTankApi.instance()