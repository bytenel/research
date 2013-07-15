class Tweet
	include Mongoid::Document
	store_in collection: "tweets", database: "undergrad_research", session: "default"
	field :text, type: String
	field :created_at, type: String 
	field :coordinates, type: Hash 
	field :user, type: Hash 
	field :entities, type: Hash 
	field :id, type: Integer 
	field :id_str, type: Integer

	attr_readonly :text, :created_at, :coordinates,
				  :user, :entities, :id, :id_str	
end