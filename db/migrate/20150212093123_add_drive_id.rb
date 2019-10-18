class AddDriveId < ActiveRecord::Migration[5.2]
  def change
    add_column :albums, :drive_id, :integer
    rename_column :albums, :confirmed, :incorrect
  end
end
