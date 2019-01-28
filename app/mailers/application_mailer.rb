# frozen_string_literal: true

##
# Manages email dispatches.
class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'
end
