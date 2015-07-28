class AddSourceToSources < ActiveRecord::Migration
  def change
    add_column :sources, :origin_site, :string
  end
end
