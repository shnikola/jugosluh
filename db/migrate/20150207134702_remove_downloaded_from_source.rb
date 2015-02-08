class RemoveDownloadedFromSource < ActiveRecord::Migration
  def change
    remove_column :sources, :downloaded
  end
end
