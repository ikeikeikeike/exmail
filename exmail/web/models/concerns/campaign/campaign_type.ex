defmodule Exmail.Concerns.Campaign.CampaignType do
  @moduledoc """
  Common functions and module for Campaign children model, that should be to DRY.
  """

  defmacro __using__(_opts) do
    quote do

      ## Functions
      #
      #
      import Chexes

      @doc """
      Parse scheduler params and returns `Ecto.Changeset`
      """
      def schedule_changeset(struct, params) do
        s = params["schedule"]

        schedule =
          cond do
            s == "cancel" ->
              nil

            present?(s) ->
              {:ok, d, _diff} =
                DateTime.from_iso8601(s)
              d

            true ->
              DateTime.utc_now
          end

        struct
        |> changeset()
        |> put_change(:schedule, schedule)
      end


      ## Generate relevent image models.
      #
      #
      defmodule Image do
        use Exmail.Web, :model

        @campaign_module __MODULE__ |> Module.split |> Enum.drop(-1) |> Module.concat
        @campaign_name Exmail.Func.thename(@campaign_module)

        @primary_key false
        schema "#{@campaign_name}s_images" do
          belongs_to :"#{@campaign_name}", @campaign_module, define_field: false
          belongs_to :image, Exmail.Image, define_field: false

          field :"#{@campaign_name}_id", :integer, primary_key: true
          field :image_id, :integer, primary_key: true

          timestamps()
        end

        @requires [:"#{@campaign_name}_id", :image_id]
        @castable [:"#{@campaign_name}_id", :image_id]

        def changeset(struct, params \\ %{}) do
          struct
          |> cast(params, @castable)
          |> validate_required(@requires)
          |> unique_constraint(:"#{@campaign_name}_id", name: :"#{@campaign_name}s_images_#{@campaign_name}_id_image_id_index")
          |> unique_constraint(:image_id, name: :"#{@campaign_name}s_images_image_id_#{@campaign_name}_id_index")
        end
      end


      ## Macro
      #
      #
      import unquote(__MODULE__), only: [track_open: 1, track_html_click: 1, track_text_click: 1]

      Module.register_attribute(__MODULE__, :track_open,       accumulate: false)
      Module.register_attribute(__MODULE__, :track_html_click, accumulate: false)
      Module.register_attribute(__MODULE__, :track_text_click, accumulate: false)

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro track_open(bool) do
    quote do
      Module.put_attribute(__MODULE__, :track_open,       unquote(bool))
    end
  end
  defmacro track_html_click(bool) do
    quote do
      Module.put_attribute(__MODULE__, :track_html_click, unquote(bool))
    end
  end
  defmacro track_text_click(bool) do
    quote do
      Module.put_attribute(__MODULE__, :track_text_click, unquote(bool))
    end
  end

  @doc false
  defmacro __before_compile__(_env) do
    quote do
      def track_open do
        @track_open
      end
      def track_html_click do
        @track_html_click
      end
      def track_text_click do
        @track_text_click
      end
    end
  end

end
