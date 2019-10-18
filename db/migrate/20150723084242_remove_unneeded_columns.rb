class RemoveUnneededColumns < ActiveRecord::Migration[5.2]
  def change
    remove_column :sources, :in_yu
    remove_column :albums, :incorrect
  end
end
