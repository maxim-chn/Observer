# frozen_string_literal: true

require 'singleton'

module Departments
  module Archive
    module Services
      ##
      # Scopes methods that might be useful to any component inside {Departments::Archive}.
      class QueryHelper
        include Singleton

        # @param [Integer] page Records of interest belong to this page.
        # @param [Integer] page_size Amount of records per page.
        # @return [Integer]
        def records_to_skip(page, page_size)
          validate_page(page)
          validate_page_size(page_size)
          (page - 1) * page_size
        end

        private

        def validate_page(value)
          return if value.class == Integer && value.positive?

          throw StandardError.new("#{self.class.name} - #{__method__} - expected page to be an\
             #{Integer.name} greater than 0.")
        end

        def validate_page_size(value)
          return if value.class == Integer && value.positive?

          throw StandardError.new("#{self.class.name} - #{__method__} - expected page_size to be an\
             #{Integer.name} greater than 0.")
        end
      end
    end
  end
end
