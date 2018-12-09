require("#{Rails.root}/app/departments/think_tank/think_tank_api.rb")
# First time call for singleton.
# Hopefully, it will instantiate properly
# and any future reference to instance() will be to exact same object
Departments::ThinkTank::ThinkTankApi.instance()