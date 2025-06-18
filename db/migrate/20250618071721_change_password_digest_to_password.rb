class ChangePasswordDigestToPassword < ActiveRecord::Migration[7.1]
  def change
    rename_column :users, :password_digest, :password
  end
end
