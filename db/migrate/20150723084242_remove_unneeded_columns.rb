class RemoveUnneededColumns < ActiveRecord::Migration
  def change
    remove_column :sources, :in_yu
    remove_column :albums, :incorrect
  end
end
