Socks
========

Library for managing web-socket centric applications

More features and documentation to come soon!
You can find a demonstration of the library over at the 
[FunWithSocks](https://github.com/gabeklein/FunWithSocks) Repo!


Socks is a small collection of helper modules indented to make it easier
to route and manage interactions between [cowboy](https://github.com/ninenines/cowboy) web-socket connections and GenServer
processes. Socks provides consistent abstractions which, for one, implicitly 
maintains or merges state of a process, be it socket delegate or GenServer actor. 

## What does it do?

Socks makes it easier to organize commands available to connected clients on a 
contextual level. Socket processes are assigned roles in-state that define, for
a given role, what the process does, by what the underlying client may ask for. 
This allows you to build protocols, with inheritance chaining, and assign them to 
application clients on-demand.

## Installation

Get it from Github:

```elixir
def deps do
  {:socks, github: "gabeklein/Socks"}
end
```

Then run `mix deps.get`.

## Contributing
Ask me; I'm new at this.

## License
MIT. See the `LICENSE` file for more details.