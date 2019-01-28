# frozen_string_literal: true

##
# Any model extends [ApplicationRecord].
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
