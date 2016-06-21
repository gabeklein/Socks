defmodule Socks.Handle do
  import :cowboy_req, only: [compact: 1, set_resp_header: 3]
  import Application, only: [get_env: 2]

  defp config(a) do 
    case a do
      :endpoint -> INewClient
      :api -> "app-api"
    end
  end

  #get_env(:routr, a)

  def websocket_init(_transport, req, _) do
    req = set_resp_header("Sec-WebSocket-Protocol", config(:api), compact(req))
    {:ok, req, { config(:endpoint) , %{}}, :hibernate}
  end

  def websocket_handle( {:text, message}, req, {route, state}) do
    route.handle_mesg(message, state)
      |> websocket_return(state, route, req)
  end

  def websocket_handle( _data, req, state) do
    {:ok, req, state}
  end

  def websocket_info(info, req, {route, state}) do
    route.handle_info(info, state)
      |> websocket_return(state, route, req)
  end

  def websocket_info({_timeout, _ref, :closeconnection}, req, _st), do: {:shutdown, req, nil}

  defp websocket_return({reply?, nstate, nroute}, state, route, req) do
    state = {nroute || route, case nstate do
      nil            -> state
      {:new, nstate} -> nstate
      nstate = %{}   -> Map.merge(state, nstate)
    end}
    case reply? do
      {_, :nothing} -> {:ok,            req, state} #, :hibernate}
      {:text, _}    -> {:reply, reply?, req, state} #, :hibernate}
      :shutdown     -> {:shutdown,      req, state}
    end
  end

  def init({_tcp, _http}, _req, _opts), do: {:upgrade, :protocol, :cowboy_websocket}
  def websocket_terminate(_reason, _req, _state), do: :ok
end