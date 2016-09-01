defmodule Socks.Fallback do
	use Socks.Role

	get "ping", do: return "pong"

	fallback message: "SERVER FAULT: More like, developer's fault, amiright??"
end