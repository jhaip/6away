# Load the rails application
require File.expand_path('../application', __FILE__)

Tutorial::Application.configure do

	config.action_mailer.delivery_method = :smtp
	config.action_mailer.raise_delivery_errors = true

end

# Initialize the rails application
Tutorial::Application.initialize!
