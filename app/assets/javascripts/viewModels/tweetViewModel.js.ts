
declare var $: any;
declare var ko: any;

module twitterResearch {
	class Tweet{
			text: string;
			created_at: string;
			coordinates: string;
			user: string;
			entities: string;
			id: number;
			id_str: string;

			constructor(_text: string, _created_at: string, _coordinates: string, _user: string,
					    _entities: string, _id_str: string, _id: number){

				this.text = _text;
				this.created_at = _created_at;
				this.coordinates = _coordinates;
				this.user = _user;
				this.entities = _entities;
				this.id_str = _id_str;
				this.id = _id;
			}
	}

	export class TweetViewModel{
	
		    tweetsArray = ko.observableArray([]); 
		    tweet = ko.observableArray([]);
			constructor()
			{
			}

			//tweet is going to be the JSON tweet we return 
			//from the server
			pushTweet(tweet)
			{
				var _tweet = {
					text: tweet.text,
					created_at: tweet.created_at,
					coordinates: tweet.coordinates,
					user: tweet.user,
					entities: tweet.entities,
					id_str: tweet.id_str,
					id: tweet.id
				};		
				this.tweetsArray.push(_tweet);
				this.tweetsArray.valueHasMutated();
			}
	}
}


