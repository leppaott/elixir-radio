defmodule ElixirRadio.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import Plug.Conn
      import Plug.Test
      import ElixirRadio.ConnCase
      import ElixirRadio.Factory

      alias ElixirRadio.Repo

      # Helper functions for making requests
      def get(conn, path) do
        Plug.Test.conn(:get, path)
        |> ElixirRadio.StreamingServer.call([])
      end

      def post(conn, path, params) do
        Plug.Test.conn(:post, path)
        |> put_req_header("content-type", "multipart/form-data")
        |> Map.put(:body_params, params)
        |> Map.put(:params, params)
        |> ElixirRadio.StreamingServer.call([])
      end

      # Helper to parse JSON responses
      def json_response(conn, status) do
        assert conn.status == status
        Jason.decode!(conn.resp_body)
      end
    end
  end

  setup tags do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(ElixirRadio.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)

    {:ok, conn: build_conn()}
  end

  @doc """
  Setup helper that creates a test connection.
  """
  def build_conn do
    Plug.Test.conn(:get, "/")
  end
end
