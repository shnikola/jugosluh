class Source < ActiveRecord::Base
  belongs_to :album
  
  scope :interesting, -> { where(in_yu: true) }
  scope :unconnected, -> { where(album_id: nil) }
  
  scope :to_download, -> { where(downloaded: 0).where("album_id IS NOT NULL") }
  scope :downloaded, -> { where(downloaded: 1) }
  
  def clean_title
    title.gsub(/19\d\d/, '').gsub(/\-\s?\d\s?\-/, '') if title # years confuse me
  end
  
end