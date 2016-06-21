defmodule Socks.Actor do

	defmacro __using__(_opts) do
		quote do
			use GenServer
			import GenServer, only: [call: 2, cast: 2]
			import Routr.Ops, only: [return: 1, return: 2, return: 3]

			def start(args) when is_list(args) do 
				{:ok, pid} = GenServer.start_link(__MODULE__, args)
				pid
			end

			alias Socks.Actor
			import Actor.Ops
			import Actor.Macros
		end
	end
	
	defmodule Ops do

		defp arg(com, nil), do: com
		defp arg(com, args), do: quote(do: {unquote(com), unquote(args)})

		defmacro cast(command, args \\ nil, state, [do: block]) do # FIX THIS; ITS STUPID
			query = arg(command, args)
			quote do
				def handle_call(unquote(query), unquote(state) = current_state) do
					{:noreply, newState(unquote(block), current_state)}
				end
			end
		end

		defmacro info(command, args \\ nil, state, [do: block]) do
			query = arg(command, args)
			quote do
				def handle_info(unquote(query), unquote(state) = current_state) do
					{:noreply, newState(unquote(block), current_state)}
				end
			end
		end

		defmacro call(command, args \\ nil, state, src \\ quote(do: _), [do: block]) do
			query = arg(command, args)
			quote do
				def handle_call(unquote(query), unquote(src), unquote(state) = current_state) do
					{:push_state, response, state_update} = unquote(block)
					{:reply, response, newState(state_update, current_state)}
				end
			end
		end

		def newState(new_state, state) do
			case new_state do
				%{} when is_map(state) -> Map.merge(state, new_state)
				nil                    -> state
				{:reset, new_state}    -> new_state
				_                      -> new_state
			end
		end

	end

	defmodule Macros do

		defmacro role(name, fallback \\ nil, block) do
			quote do
				defmodule unquote(name) do
					use Routr, unquote(fallback)
					unquote(block)
				end
			end
		end

		defmacro listenWith(state) do quote do
			def init(_), do: {:ok, unquote(state)}
		end end 

		defmacro emit(val, nst \\ nil) when val != nil do quote do
			{:push_state, unquote(val),  unquote(nst) }
		end	end

		defmacro save(nst) do quote do
			{:push_state, nil, unquote(nst)}
		end end

	end
end