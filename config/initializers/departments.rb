# ##################################################
# Load enums and classes shared by departments.
# ##################################################
require("#{Rails.root}/app/departments/demo/shared/analysis_query.rb")
require("#{Rails.root}/app/departments/demo/shared/analysis_type.rb")
require("#{Rails.root}/app/departments/demo/shared/intelligence_format.rb")
require("#{Rails.root}/app/departments/demo/shared/intelligence_query.rb")
# ##################################################
# Load departments.
# ##################################################
require("#{Rails.root}/app/departments/demo/analysis/api.rb")
require("#{Rails.root}/app/departments/demo/archive/api.rb")
require("#{Rails.root}/app/departments/demo/intelligence/api.rb")
require("#{Rails.root}/app/departments/demo/think_tank/api.rb")
# ##################################################
# First time call for Singletons.
# ##################################################
Departments::Demo::Archive::Api.instance()
Departments::Demo::ThinkTank::Api.instance()