class DatabaseSync

  def start
    pull_ratings
    push_all
  end

  def pull_ratings
    p "Pulling user ratings..."
    UserRating.delete_all

    user_ratings = []
    ProductionUserRating.find_each do |user_rating|
      user_ratings << UserRating.new(user_rating.attributes)
    end

    user_ratings.each_slice(1000) do |ratings|
      UserRating.import(ratings)
    end

    p "Recalculating ratings"
    Album.includes(:user_ratings).where(id: user_ratings.map(&:album_id)).find_each do |album|
      album.calculate_average_rating
    end
  end

  def push_all
    p "Collecting info..."
    production_albums = []
    Album.find_each do |album|
      production_albums << ProductionAlbum.new(album.attributes)
    end

    p "Cleaning production database..."
    ProductionAlbum.delete_all

    p "Pushing to production..."
    production_albums.each_slice(1000) do |albums|
      ProductionAlbum.import(albums)
    end
  end

end

class ProductionAlbum < Album
  establish_connection(:production)
end

class ProductionUserRating < UserRating
  establish_connection(:production)
end
