defmodule Exmail.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string

      ## XXX: will create below like device operations

      ## Recoverable
      # add :reset_password_token, :string
      # add :reset_password_sent_at, :datetime

      ## Rememberable
      # add :remember_created_at, :datetime

      ## Trackable
      # add :sign_in_count, :integer  , default: 0, null: false
      # add :current_sign_in_at, :datetime
      # add :last_sign_in_at, :datetime
      # add :current_sign_in_ip, :string
      # add :last_sign_in_ip, :string

      ## Confirmable
      # add :confirmation_token, :string
      # add :confirmed_at, :datetime
      # add :confirmation_sent_at, :datetime
      # add :unconfirmed_email, :string    # Only if using reconfirmable

      ## Lockable
      # add :failed_attempts, :integer  , default: 0, null: false # Only if lock strategy is :failed_attempts
      # add :unlock_token, :string    # Only if unlock strategy is :email or :both
      # add :locked_at, :datetime

      timestamps
    end
    create unique_index(:users, [:email])

  end
end
