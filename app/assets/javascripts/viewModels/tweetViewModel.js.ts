declare var $: any;
declare var _:any;
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
			page: any;
			private per_page: number;
			total_pages: any;
			paginated: any;
			hasPrevious: any;
			hasNext: any;
			constructor()
			{
				var self = this;
				self.tweetsArray = ko.observableArray([]);
				self.page = ko.observable(0);
				self.per_page = 5;
				self.total_pages = ko.computed(function(){
					 var div = Math.floor(self.tweetsArray().length / self.per_page);
			         div += self.tweetsArray().length % self.per_page > 0 ? 1 : 0;
			         return div - 1;
					});

				self.paginated = ko.computed(function(){
					var first = self.page() * self.per_page;
					return self.tweetsArray().slice(first,first + self.per_page);
				});
				self.hasPrevious = ko.computed(function(){
					return self.page() !== 0;
				});
				self.hasNext = ko.computed(function(){
				return self.page() !== self.total_pages();
				});
			}

			//tweet is going to be the JSON tweet we return 
			//from the server
			pushTweet(tweetArr)
			{
				var self = this;
				_.each(tweetArr, function(tweet){
					var _tweet = new Tweet(tweet.text, tweet.created_at, tweet.coordinates,
									   tweet.user, tweet.entities, tweet.id_str, tweet.id);
				self.tweetsArray.push(_tweet);
				self.tweetsArray.valueHasMutated();
				});
			}

			

			next(){
				var self = this;
				if(self.page() < self.total_pages())
				{
					self.page(self.page()+1);
				}
			}
			previous()
			{
				var self = this;
				if(self.page() != 0){
					self.page(self.page() - 1);
				}
			}
	}
}


