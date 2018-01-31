defmodule Exmail.BaseUploader do
  defmacro __using__(_opts) do
    quote do
      alias Exmail.{Hash}

      def s3_object_headers(_version, {file, _scope}) do
        [content_type: Plug.MIME.path(file.file_name)] # for "image.png", would produce: "image/png"
      end

      def filename(version, {file, _model}) do
        case __storage() do
          Arc.Storage.Local ->
            "#{version}_#{file.file_name}"
          Arc.Storage.S3 ->
            "#{version}_#{Hash.encrypt file.file_name}"
        end
      end

      def storage_dir(_version, {_file, model}) do
        dirname = Exmail.Func.thename model
        "uploads/#{dirname}/#{Hash.encrypt model.id}"
      end

      def default_url(:original) do
        "https://placehold.it/700x800&text=SAMPLE IMAGE"
      end

      def has_doc?({file, scope}, version \\ :original) do
        url({file, scope}, version) != default_url(:original)
      end

      def develop_url({file, scope}, version \\ :original) do
        case __storage() do
          Arc.Storage.Local ->
            Path.join Exmail.Endpoint.url, url({file, scope}, version)
          Arc.Storage.S3 ->
            url({file, scope}, version)
        end
      end

      defoverridable [
        s3_object_headers: 2,
        filename: 2,
        storage_dir: 2,
        default_url: 1,
        has_doc?: 2,
        develop_url: 2
      ]
    end
  end
end
