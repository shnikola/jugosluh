class AddUploadAccessToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :upload_access, :boolean, default: false
  end
end
