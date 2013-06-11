//build ViewModel for tweets here
module twitterResearch {
	export interface tweet{
			text: string;
			created_at: string;
			coordinates: string;
			user: string;
			entities: string;
			id: number;
			id_str: string;
	}

	export class TweetViewModel implements tweet{

			constructor(arguments: any)
			{
			
				this.text = arguments['text'];
				this.created_at = arguments['created_at'];
				this.coordinates = arguments['coordinates'];
				this.user = arguments['user'];
				this.entities = arguments['entities'];
				this.id_str = arguments['id_str'];
				this.id = arguments['id'];

			}
	}
}