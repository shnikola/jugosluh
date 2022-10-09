class DiscogsRelease < ApplicationRecord

  enum status: { pending: 0, confirmed: 1, duplicate: 2, skip: 3 }

  def self.create_from_discogs(record)
    release = new(id: record[:id])
    release.update_from_discogs(record)
    release
  end

  def changed_from_discogs?(record)
    discogs_to_attributes(record).any?{|attr, value| public_send(attr) != value}
  end

  def update_from_discogs(record)
    update(discogs_to_attributes(record))
  end

  def labels
    read_attribute(:labels)&.split(";;")
  end

  def labels=(value)
    write_attribute(:labels, value&.join(";;"))
  end

  private

  def discogs_to_attributes(record)
    {
      id: record[:id],
      title: record[:title],
      catno: record[:catno],
      year: record[:year] == 0 ? nil : record[:year].to_i,
      cover_image: record[:cover_image],
      labels: record[:label],
      discogs_master_id: record[:master_id] == 0 ? nil : record[:master_id].to_s,
    }
  end
end
