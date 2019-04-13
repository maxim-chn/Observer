# frozen_string_literal: true

##
# Scopes the classes that represent Code Injection attack reports, i.e. {CodeInjection::SqlInjectionReport}.
module CodeInjection
  ##
  # A class for SQL injection interpretation data.
  class SqlInjectionReport < CyberReport
    # Relation to {FriendlyResource} model.
    belongs_to :friendly_resource, class_name: 'FriendlyResource'

    # String representation of an object.
    # @return [String]
    def inspect
      result = {}
      result['reason'] = reason
      JSON.generate(result)
    end
  end
end
