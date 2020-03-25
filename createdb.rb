# Set up for the application and database. DO NOT CHANGE. #############################
require "sequel"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB = Sequel.connect(connection_string)                                                #
#######################################################################################

# Database schema - this should reflect your domain model
DB.create_table! :places do
    primary_key :id
    String :name 
    
end 

DB.create_table! :reviews do
    primary_key :id
    foreign_key :place_id
    foreign_key :user_id
    String :reviewer
    Integer :rating
    String :comments, text: true

end
DB.create_table! :users do
    primary_key :id
    String :username
    String :phone_number
    String :email
    String :password

end

# Insert initial (seed) data
places_table = DB.from(:places)

places_table.insert(name: "Paris", 
                   )

places_table.insert(name: "Bangkok", 
                    )

places_table.insert(name: "Idaho", 
                  )                 

                   