require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module StockPortfolioSimulator
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Use sidekiq
  	config.active_job.queue_adapter = :sidekiq
    config.action_mailer.deliver_later_queue_name = 'default_mailer_queue'

    # Add fonts
    config.assets.enabled = true
    config.assets.paths << Rails.root.join("app", "assets", "fonts", "icons")
    config.assets.paths << Rails.root.join('/app/assets/fonts')

    # Include the authenticity token in remote forms.
    config.action_view.embed_authenticity_token_in_remote_forms = true
  end
end
