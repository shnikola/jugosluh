class AddStatusToSource < ActiveRecord::Migration
  def change
    add_column :sources, :status, :integer, default: 0
  end
end
