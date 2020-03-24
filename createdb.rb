# Set up for the application and database. DO NOT CHANGE. #############################
require "sequel"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB = Sequel.connect(connection_string)                                                #
#######################################################################################

# Database schema - this should reflect your domain model
DB.create_table! :places do
    primary_key :id
    String :name 
    String :rating
    String :comments, text: true
end 

DB.create_table! :reviews do
    primary_key :id
    foreign_key :place_id
    foreign_key :user_id
    String :reviewer
    String :rating
    String :comments, text: true

end
DB.create_table! :users do
    primary_key :id
    String :username
    String :email
    String :password

end

# Insert initial (seed) data
places_table = DB.from(:places)

places_table.insert(name: "Paris", 
                    rating: "4",
                    comments: "Best place,I've ever visited. Loved the food, has a great view as well."
                   )

places_table.insert(name: "Bangkok", 
                    rating: "3",
                    comments: "Loved the Thai menu. Pretty affordable too."
                   )

places_table.insert(name: "Idaho", 
                    rating: "4",
                    comments: "Great American comfort food and breakfast. Great bang for your buck!"
                   )                 

                   