# frozen_string_literal: true

require 'singleton'
require_relative './query_helper.rb'
require_relative './validation'

module Departments
  module Archive
    module Services
      ##
      # Consumes the model {CodeInjection::SqlInjectionReport}.
      class SqlInjectionReport
        include Singleton

        # Counts the amount of the {CodeInjection::SqlInjectionReport} records
        # related to a particular {FriendlyResource}.
        # @param [Integer] id {FriendlyResource} id.
        # @return [Integer]
        def count_records(id)
          Validation.instance.id?(id)
          Rails.logger.info("#{self.class.name} - #{__method__} - #{id}.") if Rails.env.development?
          CodeInjection::SqlInjectionReport.where("friendly_resource_id = #{id}").count
        end

        # Retrieves a page of persisted {CodeInjection::SqlInjectionReport} in desc order, by @created_at [DateTime].
        # @param [Integer] id {FriendlyResource} id.
        # @param [Integer] page Records of interest belong to this page.
        # @param [Integer] page_size Size of a page.
        # @return [Array<CodeInjection::SqlInjectionReport>]
        def latest_reports_by_friendly_resource_id(id, page, page_size)
          Validation.instance.id?(id)
          Validation.instance.page?(page)
          Validation.instance.page_size?(page_size)
          if Rails.env.development?
            logger_message = "#{self.class.name} - #{__method__} - #{id}, #{page}, #{page_size}."
            Rails.logger.info(logger_message)
          end
          records_to_skip = QueryHelper.instance.records_to_skip(page, page_size)
          CodeInjection::SqlInjectionReport.where(
            'friendly_resource_id = ?',
            id
          ).order('created_at desc').limit(page_size).offset(records_to_skip).to_a
        end

        # @param [Integer] id {CodeInjection::SqlInjectionReport} id.
        # @return [CodeInjection::SqlInjectionReport]
        def report_by_id(id)
          Validation.instance.id?(id)
          Rails.logger.info("#{self.class.name} - #{__method__} - #{id}.") if Rails.env.development?
          CodeInjection::SqlInjectionReport.find(id)
        end

        # @return [CodeInjection::SqlInjectionReport]
        def new_report_object
          Rails.logger.info("#{self.class.name} - #{__method__}.") if Rails.env.development?
          CodeInjection::SqlInjectionReport.new
        end
      end
    end
  end
end
