defmodule TeamAsh.Engagements do
  alias TeamAsh.Engagements.Engagement
  alias TeamAsh.Engagements.Client
  use Ash.Domain

  resources do
    resource Engagement do
      define :create_engagement, action: :create
      define :list_engagements, action: :read
      define :update_engagement, action: :update
      define :destroy_engagement, action: :destroy
      define :get_engagement, args: [:id], action: :by_id
    end

    resource Client do
      define :create_client, action: :create
      define :list_clients, action: :read
      define :update_client, action: :update
      define :destroy_client, action: :destroy
      define :get_client, args: [:id], action: :by_id
    end
  end

end
