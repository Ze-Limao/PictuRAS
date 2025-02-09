import Config

# Configures Swoosh API Client
config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: ProjectsApi.Finch

# Disable Swoosh Local Memory Storage
config :swoosh, local: false

# Do not print debug messages in production
config :logger, level: :info

# Configure other microsservices URLs
config :projects, :microservices,
  users: "http://picturas-users:4001"

# Configures RabbitMQ
config :amqp,
  connection: [url: "amqp://guest:guest@rabbitmq:5672"],
  channel: []

# Configures tools config file location
config :projects, :tools, path: "/app/data/tools.json"

# Configures images upload directory
config :projects, :uploads, path: "/images/"

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.
