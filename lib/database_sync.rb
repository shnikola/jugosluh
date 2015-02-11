class DatabaseSync
  
  def start
    pull_confirmed
    push_all
  end
  
  def pull_confirmed
    confirmed_ids = ProductionAlbum.where(confirmed: true).pluck(:id)
    confirmed_ids.each_slice(100) do |ids|
      Album.where(id: ids).update_all(confirmed: true)
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