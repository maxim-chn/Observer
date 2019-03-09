# frozen_string_literal: true

##
# Any model in the application extends this class.
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
