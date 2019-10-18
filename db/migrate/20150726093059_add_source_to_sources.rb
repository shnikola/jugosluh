class AddSourceToSources < ActiveRecord::Migration[5.2]
  def change
    add_column :sources, :origin_site, :string
  end
end
