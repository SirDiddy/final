# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
require "twilio-ruby"                                                                 #
require "bcrypt"   
require "geocoder"
require "forecast_io"
                                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts; puts "--------------- NEW REQUEST ---------------"; puts }             #
after { puts; }                                                                       #
#######################################################################################

ForecastIO.api_key = "f1a2aea7e88a73ac70215f2b871e02cd"


places_table = DB.from(:places)
reviews_table = DB.from(:reviews)
users_table = DB.from(:users)

before do
     @current_user=users_table.where(id: session["user_id"]).to_a[0]
end

  @users_table=users_table
get "/" do 
    puts "params: #{params}"
    pp places_table.all.to_a
    @places = places_table.all.to_a
    @reviews = reviews_table.all.to_a
    view "places"
end 

get "/places/:id" do 
    puts "params: #{params}"
 

    @users_table=users_table

    pp places_table.where(id: params["id"]).to_a[0]
    @place = places_table.where(id: params["id"]).to_a[0]
    @reviews = reviews_table.where(place_id: @place[:id]).to_a
    @rating_count = reviews_table.where(place_id: @place[:id]).count
    #@reviews_sum = reviews_table.where(place_id: @place[:id]).sum
    #@average_rating = @reviews_sum/@reviews_count
    
   puts "@place is #{@place[:name]}"
    results = Geocoder.search(@place[:name])
    lat_lng = results.first.coordinates
    puts results
    @lat = lat_lng[0]
    @lng = lat_lng[1]
    
    #shows the latitude
    #puts @lat
    
    #shows the longitude
    #puts @lng

    #obtains the current weather 
    forecast = ForecastIO.forecast(@lat,@lng).to_hash
    @current_temp = forecast["currently"]["temperature"]
    @current_summary = forecast["currently"]["summary"]


    view "place"
end

get "/places/:id/reviews/new" do
    puts "params: #{params}"
    @place = places_table.where(id: params["id"]).to_a[0]
    view "new_review"
end 

get "/places/:id/reviews/create" do
    puts "params: #{params}"
    @place = places_table.where(id: params["id"]).to_a[0]
    reviews_table.insert(
        place_id: @place[:id],
        user_id: session["user_id"],
        rating: params["rating"],
        comments: params["comment"]
    )
    view "create_review"
end 

get "/users/new" do
    view "new_user"
end

post "/users/create" do
    puts "params: #{params}"
    users_table.insert(
        username: params["name"],
        email: params["email"],
        password: BCrypt::Password.create(params["password"])
    )
    view "create_user"
end

get "/logins/new" do
    view "new_login"
end

post "/logins/create" do
    puts "params: #{params}"
    @user = users_table.where(email: params["email"]).to_a[0]
    if @user 
        if BCrypt::Password.new(@user[:password]) == params["password"]
            session["user_id"] = @user[:id]
            view "create_login"
        else
            view "create_login_failed"
        end
    else
        view "create_login_failed"
    end
end


get "/logout" do

    session["user_id"] = nil
    view "logout"
end
