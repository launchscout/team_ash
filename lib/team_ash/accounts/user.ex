defmodule TeamAsh.Accounts.User do
  use Ash.Resource,
    domain: TeamAsh.Accounts,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication]

  attributes do
    uuid_primary_key :id

    attribute :email, :ci_string do
      allow_nil? false
      public? true
    end

    attribute :hashed_password, :string, allow_nil?: false, sensitive?: true
  end

  authentication do
    strategies do
      password :password do
        identity_field :email
      end
    end

    tokens do
      enabled? true
      token_resource TeamAsh.Accounts.Token
      signing_secret TeamAsh.Accounts.Secrets
    end
  end

  postgres do
    table "users"
    repo TeamAsh.Repo
  end

  identities do
    identity :unique_email, [:email]
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  # If using policies, add the following bypass:
  # policies do
  #   bypass AshAuthentication.Checks.AshAuthenticationInteraction do
  #     authorize_if always()
  #   end
  # end
end
