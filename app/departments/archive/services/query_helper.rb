# frozen_string_literal: true

require 'singleton'
require_relative './validation'

module Departments
  module Archive
    module Services
      ##
      # Scopes methods for database querying that might be useful to any component inside {Departments::Archive}.
      class QueryHelper
        include Singleton

        # @param [Integer] page Records of interest belong to this page.
        # @param [Integer] page_size Amount of records per page.
        # @return [Integer]
        def records_to_skip(page, page_size)
          Validation.instance.page?(page)
          Validation.instance.page_size?(page_size)
          (page - 1) * page_size
        end
      end
    end
  end
end
