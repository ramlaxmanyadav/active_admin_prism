Devise.setup do |config|
  require "devise/orm/active_record"
  config.mailer_sender = "test@example.com"
  config.stretches = 1
  config.responder.error_status = :unprocessable_content
  config.responder.redirect_status = :see_other
end
