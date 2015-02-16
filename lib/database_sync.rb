class DatabaseSync
  
  def start
    pull_ratings
    push_all
  end
  
  def pull_ratings
    p "Cleaning production database..."
    UserRating.delete_all
    
    p "Pulling user ratings..."
    user_ratings = []
    ProductionUserRating.find_each do |user_rating|
      user_ratings << UserRating.new(user_rating.attributes)
    end
    
    user_ratings.each_slice(1000) do |ratings|
      UserRating.import(ratings)
    end
  end
  
  def push_all
    p "Cleaning production database..."
    ProductionAlbum.delete_all
    
    p "Collecting info..."
    production_albums = []
    Album.find_each do |album|
      production_albums << ProductionAlbum.new(album.attributes)
    end
    
    p "Pushing to production..." 
    production_albums.each_slice(1000) do |albums|
      ProductionAlbum.import(albums)
    end
  end
  
end



class ProductionAlbum < Album
  establish_connection(
    adapter: "postgresql",
    host: '163.47.63.206',
    port: 5432,
    encoding: 'utf8',
    username: "app",
    password: ENV['PRODUCTION_DATABASE_PASSWORD'],
    database: "db13099"
  )
  
end

class ProductionUserRating < UserRating
  establish_connection(
    adapter: "postgresql",
    host: '163.47.63.206',
    port: 5432,
    encoding: 'utf8',
    username: "app",
    password: ENV['PRODUCTION_DATABASE_PASSWORD'],
    database: "db13099"
  )
  
end