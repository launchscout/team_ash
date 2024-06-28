defmodule TeamAsh.Engagements.Engagement do
  alias TeamAsh.Engagements
  alias TeamAsh.Engagements.Client
  use Ash.Resource,
    domain: Engagements,
    data_layer: AshPostgres.DataLayer

  resource do
    plural_name :engagements
  end

  postgres do
    table "engagements"

    repo TeamAsh.Repo
  end

  actions do
    # Exposes default built in actions to manage the resource
    defaults [:read, :destroy]

    create :create do
      # accept title as input
      accept [:starts_on, :ends_on, :name, :client_id]
    end

    update :update do
      # accept content as input
      accept [:starts_on, :ends_on, :name, :client_id]
    end

    # Defines custom read action which fetches post by id.
    read :by_id do
      # This action has one argument :id of type :uuid
      argument :id, :uuid, allow_nil?: false
      # Tells us we expect this action to return a single result
      get? true
      # Filters the `:id` given in the argument
      # against the `id` of each element in the resource
      filter expr(id == ^arg(:id))
    end
  end

  preparations do
    prepare build(load: [:client])
  end

  attributes do
    # Add an autogenerated UUID primary key called `:id`.
    integer_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end

    attribute :starts_on, :date
    attribute :ends_on, :date
  end

  relationships do
    belongs_to :client, Client
  end

end
