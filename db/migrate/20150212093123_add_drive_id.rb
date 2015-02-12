class AddDriveId < ActiveRecord::Migration
  def change
    add_column :albums, :drive_id, :integer
    rename_column :albums, :confirmed, :incorrect
  end
end
