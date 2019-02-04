# frozen_string_literal: true

##
# Load enums and classes shared by departments.
require(Rails.root.join('app', 'departments', 'shared', 'analysis_query.rb'))
require(Rails.root.join('app', 'departments', 'shared', 'analysis_type.rb'))
require(Rails.root.join('app', 'departments', 'shared', 'intelligence_format.rb'))
require(Rails.root.join('app', 'departments', 'shared', 'intelligence_query.rb'))

# Load departments.
require(Rails.root.join('app', 'departments', 'analysis', 'api.rb'))
require(Rails.root.join('app', 'departments', 'archive', 'api.rb'))
require(Rails.root.join('app', 'departments', 'intelligence', 'api.rb'))
require(Rails.root.join('app', 'departments', 'think_tank', 'api.rb'))
