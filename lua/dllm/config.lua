--- @class Config
Config = {
  user_prefix = "User:",
  system_prefix = "System:",
  provider = "anthropic",
  temperature = 0.0,
  max_tokens = 3000,
  openai = {
    default_model = "gpt-4"
  },
  anthropic = {
    default_model = "claude-3"
  },
  port = 4242,
  hostname = "localhost",
}

return Config
