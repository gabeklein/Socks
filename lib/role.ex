defmodule Socks.Role do

  defmacro __before_compile__(_env) do
    quote do 
      def handle_info(q,d), do: fallback(:handle_info, q, d)
      def handle_mesg(q,d), do: fallback(:handle_mesg, q, d)
    end
  end

  defmacro __using__(mod \\ nil, opts \\ []) do

    module = case mod do
      [] ->
        case Application.get_env(:socks, :global_fallback) do
          nil -> Socks.Fallback
          mod -> mod
        end |> IO.inspect
      mod -> mod
    end

    quote do
      import Socks.Role.Ops
      import GenServer, only: [call: 2, cast: 2]


      # unquote( mod != [] && quote do
        @before_compile Socks.Role
        defp fallback(mode, query, handle), do: apply(unquote(module), mode, [query, handle])
      # end)

      unquote( opts[:registerable] && quote do
          def handle_mesg("register: " <> name, _) do
            Process.register self, :erlang.binary_to_atom(name, :utf8)
            return "Registered as #{name}, in IEX!"
          end 
      end)
    end
  end
  
  defmodule Ops do

    defmacro get(query, handle) do
      quote do
        def handle_mesg(unquote(query), _), unquote(handle)
      end
    end

    defmacro get(head, tail \\ nil, state, handle) do
      if tail 
        do head = quote(do: unquote(head <> " ") <> unquote(tail))
      end

      quote do 
        def handle_mesg(unquote(head), unquote(state)), unquote(handle)
      end

    end

    defmacro got(head, tail \\ nil, state, handle) do
      query = if tail
        do quote do {unquote(head), unquote(tail)} end
        else head
      end

      quote do 
        def handle_info(unquote(query), unquote(state)), unquote(handle)
      end

    end

    defmacro fallback([message: message]) do 
      quote do 
        def handle_info(message, _) do
          IO.puts "Unhandled message: #{inspect message} Shutdown caught!"
          return
        end
        def handle_mesg(_, _), do: return unquote(message)
      end
    end

    defmacro fallback([on: mod]) do
      quote do 
        def handle_info(qu, st), do: unquote(mod).handle_info(qu, st)
        def handle_mesg(qu, st), do: unquote(mod).handle_mesg(qu, st)
      end
    end

    def return(rs) when is_list(rs), do: apply(__MODULE__, return, rs)

    def return(rs \\ :nothing, new_state \\ nil, new_handler \\ nil) do
      {{:text, case rs do
        :nothing            -> :nothing
        _ when is_map    rs -> Poison.encode!(rs)
        _ when is_binary rs -> rs
        _ -> "error: internal (cannot serialize response)"
      end}, new_state, new_handler}
    end
  end
end