map = null;
function initialize() {
    var fusionTableId = '1Lxp4IOOyIpiyCD3LCwc4iS3HHeyQHMFZKGxEI7w';
    var sanFrancisco = new google.maps.LatLng(37.774546, -122.433523);

    //Initialize the actual map
    map = new google.maps.Map(document.getElementById('map-canvas'), {
    center: sanFrancisco,
    zoom: 4,
    mapTypeId: google.maps.MapTypeId.SATELLITE
    });

    //Add overlay
    viewMap('1Lxp4IOOyIpiyCD3LCwc4iS3HHeyQHMFZKGxEI7w', 'Location');
}

//This method is optimized to reduce API queries - be mindful when editing.
function viewMap(ID, columnName, query) {
    sql = query ? query : "";

    if (typeof standard != 'undefined' && standard)
        standard.setMap(null);

    if (typeof heatmap != 'undefined' && heatmap)
        heatmap.setMap(null);

    standard = new google.maps.FusionTablesLayer({ query: { select: columnName, from: ID, where: sql}});
    heatmap = new google.maps.FusionTablesLayer({ query: { select: columnName, from: ID, where: sql}, heatmap: { enabled: true }});

    //Use the appropriate map.
    if (document.getElementById('heatmap-toggle').checked == false)
        standard.setMap(map); //Show the dotted map by default.
    else
        heatmap.setMap(map); //Show the heatmap by default.

}

function toggleHeatmap() {
    if (standard.getMap() == null) {
        heatmap.setMap(null);
        standard.setMap(map);
    } else {
        standard.setMap(null);
        heatmap.setMap(map);
    }
}

function searchMap(searchFieldObject, statusTextObject, query) {
    UIquery = searchFieldObject.value;
    var tempUIquery = UIquery;
    if (query != UIquery) {
    statusTextObject.innerHTML = 'Searching...';
    setTimeout(function(){searchMap(searchFieldObject, statusTextObject, tempUIquery);},150);
}
else {
    viewMap('1Lxp4IOOyIpiyCD3LCwc4iS3HHeyQHMFZKGxEI7w','Location', "Text CONTAINS '" + query + "'");
    statusTextObject.innerHTML = '';
    }
}

function getTweets(container, searchQuery) {
    $.get("/tweets", { search: searchQuery })
        .done(function(data) {
            displayTweets(container, data);
        });
}

function displayTweets(container, data) {
    dataobject = JSON.parse(data);
    // TODO: Check to make sure response is formed well and successful.
    $(container).html(""); //Clear the box of any old search results.
    for (index in dataobject['results']) {
        $(container).html($(container).html() +
        '<div class="result-item">' +
        '<h4 class="tweet-user">' + dataobject['results'][index]['user']['screen_name'] + '</h4>' +
        '<span class="tweet-time">' + dataobject['results'][index]['created_at'] + '</span><br />' +
        '<span class="tweet-text">' + dataobject['results'][index]['text'] + '</span>' +
        '</div>');
    }

}

google.maps.event.addDomListener(window, 'load', initialize);
