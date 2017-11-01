defmodule IclogWeb.Schema.Observation do
  @moduledoc """
  Schema types
  """

  use Absinthe.Schema.Notation

  alias Iclog.Observable.Observation
  alias IclogWeb.ChangesetView
  alias Phoenix.View

  @desc "An observation"
  object :observation do
    field :id, :integer
    field :comment, :string
    field :meta, :observation_meta
  end

  object :observation_query do
    field :observations, list_of(:observation) do
      resolve fn(_args, _info) ->
        obs = :with_meta
          |> Observation.list()
          |> Stream.map(fn(ob) ->
              {meta, new_ob} = Map.pop(ob, :observation_meta)
              Map.put(new_ob, :meta, meta)
            end)
          |> Enum.to_list()
        {:ok, obs}
      end
    end
  end

  input_object :meta_input do
    field :title, non_null(:string)
    field :intro, :string
  end

  @desc "Create an observation with its metadata simulatenously"
  object :Observation_mutation_with_meta do
    field :observation_with_meta, type: :observation do
      arg :comment, non_null(:string)
      arg :meta, non_null(:meta_input)

      resolve fn(params, _) -> 
        {m_params, o_params} = Map.pop( params, :meta)
        
        with {:ok, data} <- Observation.create(o_params, m_params) do
          {:ok, data} # {:ok, %{data: ..}}
        else
          {:error, changeset} ->
            {:ok,  View.render(ChangesetView, "error.json", changeset: changeset)} # {:ok, %{errors: ....}}
        end
      end

    end
  end 
end