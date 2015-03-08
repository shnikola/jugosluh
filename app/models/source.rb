class Source < ActiveRecord::Base
  belongs_to :album
  
  enum status: {
    skipped: -1,            # Not related to our research
    waiting: 0,             # Initial state when scraped
    confirmed: 1,           # Confirmed to be ex-YU 
    multiple_found: 2,      # Multiple sources point to same album
    download_failed: 3,     # Download error
    download_mismatched: 4, # Track count doesn't match with discogs
    downloaded: 5           # Download ready
   }
  
  scope :unconnected, -> { where(album_id: nil) }
  scope :to_download, -> { confirmed.where("album_id IS NOT NULL") }
  
  def clean_title
    title.gsub(/19\d\d/, '').gsub(/\-\s?\d\s?\-/, '') if title # years confuse me
  end
  
end