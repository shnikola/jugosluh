class Source < ApplicationRecord
  belongs_to :album, optional: true

  enum status: {
    skipped: -1,            # Not related to our research
    waiting: 0,             # Initial state when scraped
    confirmed: 1,           # Confirmed to be ex-YU
    download_failed: 2,     # Download error
    download_mismatched: 3, # Track count doesn't match with discogs, will be sorted to incomplete, unknown, another album
    download_incomplete: 4, # Album doesn't include all tracks
    download_unknown: 5,    # Album is not in our db
    downloaded: 6,          # Download ready
    compilation: 7          # Not a regular album, but could be useful
   }

  scope :unconnected, -> { where(album_id: nil) }
  scope :to_download, -> { confirmed.where("album_id IS NOT NULL") }

  def year
    title.match(/\b(19\d\d)\b/).try(:[], 1)
  end
end
