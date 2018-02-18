defmodule Exmail.Plug.ParamsPaginator do
  # import CommonDeviceDetector.Detector

  def init(opts), do: opts
  def call(conn, _opts) do
    params =
      # if desktop?(conn) do
        %{"page_size" => "33"}
      # else
        # %{"page_size" => "10"}
      # end

    struct conn, [params: Map.merge(conn.params, params)]
  end
end
