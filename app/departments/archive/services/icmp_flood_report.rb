# frozen_string_literal: true

require 'singleton'
require_relative './query_helper.rb'
require_relative './validation'

module Departments
  module Archive
    ##
    # Supporting methods for the {Departments::Archive} module.
    module Services
      ##
      # Consumes the model {Dos::IcmpFloodReport}.
      class IcmpFloodReport
        include Singleton

        # Counts the amount of the {Dos::IcmpFloodReport} records related to a particular {FriendlyResource}.
        # @param [Integer] id {FriendlyResource} id.
        # @return [Integer]
        def count_records(id)
          Validation.instance.id?(id)
          Rails.logger.info("#{self.class.name} - #{__method__} - #{id}.") if Rails.env.development?
          Dos::IcmpFloodReport.where("friendly_resource_id = #{id}").count
        end

        # Retrieves a page of persisted {Dos::IcmpFloodReport} in desc order, by @created_at [DateTime]
        # @param [Integer] id {FriendlyResource} id.
        # @param [Integer] page Records of interest belong to this page.
        # @param [Integer] page_size Size of a page.
        # @return [Array<Dos::IcmpFloodReport>]
        def latest_reports_by_friendly_resource_id(id, page, page_size)
          Validation.instance.id?(id)
          Validation.instance.page?(page)
          Validation.instance.page_size?(page_size)
          if Rails.env.development?
            logger_message = "#{self.class.name} - #{__method__} - #{id}, #{page}, #{page_size}."
            Rails.logger.info(logger_message)
          end
          records_to_skip = QueryHelper.instance.records_to_skip(page, page_size)
          Dos::IcmpFloodReport.where(
            'friendly_resource_id = ?',
            id
          ).order('created_at desc').limit(page_size).offset(records_to_skip).to_a
        end

        # @param [Integer] id {Dos::IcmpFloodReport} id.
        # @return [Dos::IcmpFloodReport]
        def report_by_id(id)
          Validation.instance.id?(id)
          Rails.logger.info("#{self.class.name} - #{__method__} - #{id}.") if Rails.env.development?
          Dos::IcmpFloodReport.find(id)
        end

        # @param [Integer] seasonal_index A seasonal index that is used in
        # {https://ieeexplore.ieee.org/document/4542524 Modified Holt Winters Forecasting} algorithm.
        # @return [Dos::IcmpFloodReport]
        def new_report_object(seasonal_index)
          Validation.instance.seasonal_index?(seasonal_index)
          Rails.logger.info("#{self.class.name} - #{__method__} - #{seasonal_index}.") if Rails.env.development?
          Dos::IcmpFloodReport.new(seasonal_index: seasonal_index)
        end

        # @param [Integer] id {FriendlyResource} id.
        # @param [Integer] seasonal_index A seasonal index that is used in
        # {https://ieeexplore.ieee.org/document/4542524 Modified Holt Winters Forecasting} algorithm.
        # @return [Dos::IcmpFloodReport]
        def latest_report_by_friendly_resource_id_and_seasonal_index(id, seasonal_index)
          Validation.instance.id?(id)
          Validation.instance.seasonal_index?(seasonal_index)
          Rails.logger.info("#{self.class.name} - #{__method__} - #{id}, #{seasonal_index}.") if Rails.env.development?
          Dos::IcmpFloodReport.where(
            'friendly_resource_id = ? AND seasonal_index = ?',
            id,
            seasonal_index
          ).limit(1).order('created_at desc').to_a.first
        end
      end
    end
  end
end
