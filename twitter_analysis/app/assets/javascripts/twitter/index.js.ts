//control the tweet viewmodel from here to manipulate ajax calls to populate it in a ko obeservable array
module twitterResearch{
		export class Utilities{

			constructor(){

			}

			//hitting a wall with this, come back to it (TODO)
			populateViewModels(){

			}
		}

}

//document.onReady callback function
$(function() {
		$.get('ajax/test.html', function(data) {
			  $('.result').html(data);
			  alert('Load was performed.');
		});
});