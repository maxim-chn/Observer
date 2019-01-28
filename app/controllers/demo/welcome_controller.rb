# frozen_string_literal: true

module Demo
  ##
  # This class renders any resources that have general scope.
  # For example, root or about pages.
  # It is expected to consume no [API], expecially none of [Observer].
  class WelcomeController < ApplicationController
    def index
      # render demo/welcome/index.html.erb.
    end
  end
end
