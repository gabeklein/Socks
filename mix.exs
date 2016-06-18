defmodule Socks.Mixfile do
  use Mix.Project

  def project do
    [app: :socks,
     version: "0.0.2",
     elixir: "~> 1.2",
     description: "Helpers for interaction between GenServer and WebSocket actors",
     source_url: "https://github.com/gabeklein/socks",
     package: package,
     docs: docs,
     deps: deps]
  end

  def application do
    [ applications: [:loggery] ]
  end

  def docs do
    [
      readme: "README.md",
      main: Socks
    ]
  end

  defp deps do
    [ {:cowboy, ">1.0.3"} ]
  end

  defp package do
      [
        contributors: ["Gabe Klein"],
        licenses: ["MIT"],
        links: %{
          "Github" => "https://github.com/gabeklein/Socks"
        }
      ]
    end
end
