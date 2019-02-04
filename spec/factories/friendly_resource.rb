require 'ipaddr'
FactoryGirl.define do
  factory :friendly_resource do |f|
    f.name 'demo_resource'
    f.ip_address IPAddr.new("79.181.31.4")
  end
end
