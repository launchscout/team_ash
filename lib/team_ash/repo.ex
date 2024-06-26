defmodule TeamAsh.Repo do
  use AshPostgres.Repo,
    otp_app: :team_ash

  # Installs extensions that ash commonly uses
  def installed_extensions do
    ["ash-functions", "uuid-ossp", "citext"]
  end
end
