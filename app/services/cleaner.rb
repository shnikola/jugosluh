class Cleaner
  
  def list_duplicate_catnums
    album_map = Hash.new([])
    Album.original.where("catnum != ?", 'NONE').find_each do |album|
      album_map[album.label + "#" + album.catnum] += [album]
    end
    
    album_map.select!{|_, v| v.count > 1}
    album_map.values.each do |albums|
      albums.each { |a| print "[#{a.label} #{a.catnum}] #{a.artist} - #{a.title}\n"}
    end
  end
  
  def select_best_original
    Album.where("duplicate_of_id IS NOT NULL").find_each do |duplicate|
      original = duplicate.original
      if better_info?(duplicate, original)
        duplicate_attrs, original_attrs = duplicate.info_attributes, original.info_attributes
        p "Switching #{original.id} - #{duplicate.id}"
        original.update_attributes(duplicate_attrs)
        duplicate.update_attributes(original_attrs)
      end
    end
  end
  
  private
  
  def better_info?(duplicate, original)
    # If the duplicate was out earlier than the original
    duplicate.year? && duplicate.year < original.year
  end
end