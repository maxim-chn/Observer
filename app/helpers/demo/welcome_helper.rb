# frozen_string_literal: true

module Demo
  ##
  # Holds helper methods for welcome view template.
  class WelcomeHelper
    def page_title_for_welcome_view(page_details)
      "Observer sub-system | #{page_details}"
    end
  end
end
