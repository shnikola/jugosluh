class Source < ActiveRecord::Base
  belongs_to :album

  enum status: {
    skipped: -1,            # Not related to our research
    waiting: 0,             # Initial state when scraped
    confirmed: 1,           # Confirmed to be ex-YU
    incomplete: 2,          # Album doesn't include all tracks
    download_failed: 3,     # Download error
    download_mismatched: 4, # Track count doesn't match with discogs
    downloaded: 5,          # Download ready
    compilation: 6          # Not a regular album, but could be useful
   }

  scope :unconnected, -> { where(album_id: nil) }
  scope :to_download, -> { confirmed.where("album_id IS NOT NULL") }

end
