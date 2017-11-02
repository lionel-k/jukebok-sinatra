require "sinatra"
require "sinatra/reloader" if development?
require "sqlite3"

DB = SQLite3::Database.new(File.join(File.dirname(__FILE__), 'db/jukebox.sqlite'))

get "/" do
  display_artists
end

get "/artists" do
  display_artists
end

get "/artists/:artist_id" do
  display_artist_page
end

get "/albums/:album_id" do
  display_album_page
end

get "/artists/albums/:album_id" do
  display_album_page
end

get "/tracks/:track_id" do
  display_track_page
end

get "/artists/albums/tracks/:track_id" do
  display_track_page
end

def display_artists
  # TODO: Gather all artists to be displayed on home page
  sql = "select id, name from artists"
  @artists = DB.execute(sql)
  erb :home # Will render views/home.erb file (embedded in layout.erb)
end

def display_artist_page
  # 1. Create an artist page with all the albums. Display genres as well
  artist_id = params[:artist_id]
  sql = "select distinct(albums.title), genres.name, artists.name, albums.id from albums
          join artists on artists.id = albums.artist_id
          join tracks on tracks.album_id = albums.id
          join genres on genres.id = tracks.genre_id
          where artists.id = #{artist_id}"
  @results = DB.execute(sql)
  @hash_results = @results.map { |result| { album_title: result[0], genre_name: result[1], album_id: result[3] } }
  @hash_results = { albums: @hash_results, artist_name: @results.first[2] }
  erb :artists
end

def display_album_page
  # 2. Create an album pages with all the tracks
  album_id = params[:album_id]

  @album_name = DB.execute("select title from albums where id = #{album_id}").flatten!.first

  sql = "select tracks.id, tracks.name from albums
            join tracks on tracks.album_id = albums.id
            where albums.id = #{album_id}"
  @results = DB.execute(sql)
  erb :albums
end

def display_track_page
  # 3. Create a track page with all the track info
  track_id = params[:track_id]
  @track_name = DB.execute("select name from tracks where tracks.id = '#{track_id}'").flatten!.first

  sql = "select genres.name, media_types.name, composer, milliseconds, bytes, unit_price
          from tracks
          join genres on genres.id = tracks.genre_id
          join media_types on media_types.id = tracks.media_type_id
          where tracks.id = '#{track_id}'"

  @results = DB.execute(sql)
  @results.flatten!
  erb :tracks
end
