class AddStatusToSource < ActiveRecord::Migration[5.2]
  def change
    add_column :sources, :status, :integer, default: 0
  end
end
