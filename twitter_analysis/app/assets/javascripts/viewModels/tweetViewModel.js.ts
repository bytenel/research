//build ViewModel for tweets here
var $: any;
var ko: any;

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
	
			var tweetsArray = ko.obeservableArray();
			constructor()
			{
			}

			//tweet is going to be the JSON tweet we return 
			//from the server
			pushTweet(tweet)
			{
				obj = JSON.parse(json);
				_tweet = new Tweet(obj.text,obj.created_at, 
								   obj.coordinates, obj.user, obj.entities, 
								   obj.id_str, obj.id);
				tweetsArray.push(_tweet);
			}
	}
}

var viewModel = new TweetViewModel();

//document.onReady callback function
$(function() {
	  alert('Get ajax call was done.');
		$.get('twitter/2', function(data) {
			  viewModel.pushTweet(data);
			  alert(data);
			  alert('Get ajax call was done.');
		});

		ko.applyBindings(viewModel);
});

