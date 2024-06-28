defmodule TeamAsh.Accounts do

  use Ash.Domain

  resources do
    resource TeamAsh.Accounts.Token
    resource TeamAsh.Accounts.User do
      define :create_user, action: :create
    end
  end

end
