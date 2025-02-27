alias HyperLLM.{Conversation, Chat, Model, Tool}

HyperLLM.set_config(:anthropic, api_key: System.get_env("ANTHROPIC_API_KEY"))
HyperLLM.set_config(:openai, api_key: System.get_env("OPENAI_API_KEY"))
