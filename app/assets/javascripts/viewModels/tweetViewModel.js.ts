
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

			constructor(_text: string, _created_at: string, _coordinates: any, _user: any,
					    _entities: any, _id_str: string, _id: number){

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
			
			tweetsArray: any;	
			constructor()
			{
				this.tweetsArray = ko.observableArray([]);
			}

			//tweet is going to be the JSON tweet we return 
			//from the server
			pushTweet(tweet)
			{
				var _tweet = new Tweet(tweet.text, tweet.created_at, tweet.coordinates,
									   tweet.user, tweet.entities, tweet.id_str, tweet.id);
				this.tweetsArray.push(_tweet);
				this.tweetsArray.valueHasMutated();
			}
	}
}


