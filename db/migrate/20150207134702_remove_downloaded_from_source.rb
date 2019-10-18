class RemoveDownloadedFromSource < ActiveRecord::Migration[5.2]
  def change
    remove_column :sources, :downloaded
  end
end
