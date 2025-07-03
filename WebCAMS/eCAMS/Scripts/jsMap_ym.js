//<!--$$Revision: 2 $-->
//<!--$$Author: Bo $-->
//<!--$$Date: 16/05/16 11:06 $-->
//<!--$$Logfile: /eCAMSSource2010/eCAMS/Scripts/jsMap_ym.js $-->
//<!--$$NoKeywords: $-->
//<![CDATA[


/*
* Display all the markers and calculate center of all markers
*/
function bestFit(map, bounds, markerCount) 
{
    if (markerCount > 1) 
	{
        map.fitBounds(bounds);
    }
    else 
	{
        map.setCenter(bounds.getCenter());
        map.setZoom(16);
    }
}

/*
* Draw a circle on the map
*/
function drawCircle(map, bounds, center, radius, nodes, liColor, liWidth, liOpacity, fillColor, fillOpacity) 
{	
	var circleOptions = 
	{
        strokeColor: liColor,
        strokeOpacity: liOpacity,
        strokeWeight: liWidth,
        fillColor: fillColor,
        fillOpacity: fillOpacity,
        map: map,
        center: center,
        radius: radius * 1000,
		clickable: false
    };

    var mapCircle = new google.maps.Circle(circleOptions);
}

/*
* Draw a polygons on the map for suburb boundaries
*/
function drawSuburbBoundary(map, bounds, suburbBoundary, liColor, liWidth, liOpa, fillColor, fillOpa) 
{
    var boundaryPointArray = suburbBoundary.split(":"); //get each suburb boundary
    var points = [];
    for (var i = 0; i < boundaryPointArray.length; i++) 
	{
        var boundary = boundaryPointArray[i].split("|");
        for (var j = 0; j < boundary.length; j++) 
		{
            var point = new google.maps.LatLng(boundary[j].split(",")[1], boundary[j].split(",")[0]);  //boundary stored as Longitude/Latidue
            points.push(point);
        }
     
		// Construct the polygon
		var poly = new google.maps.Polygon(
			{
				paths: points,
				strokeColor: liColor,
				strokeOpacity: liOpa,
				strokeWeight: liWidth || 2,
				fillColor: fillColor || liColor || "#0055ff",
				fillOpacity: fillOpa
			}
		);
 
	   poly.setMap(map);
   }
}

/*
* Persist the event handler of markers on the map
*/
function updateMarker(marker, txt, showStreetView) 
{
    google.maps.event.addListener(marker, 'mousedown', (function (marker, txt) 
		{
			return function () 
			{
				var content = document.createElement("DIV");
				var title = document.createElement("DIV");
				var infowindow = new google.maps.InfoWindow();

				title.innerHTML = '<font face="arial" size="2">' + txt + '</font>';
				content.appendChild(title);

				if (showStreetView == "1") 
				{
					var streetview = document.createElement("DIV");
					streetview.style.width = "200px";
					streetview.style.height = "200px";
					content.appendChild(streetview);
				}

				infowindow.setContent(content);
				infowindow.open(marker.getMap(), marker);

				if (showStreetView == "1") 
				{
					google.maps.event.addListenerOnce(infowindow, "domready", function () 
						{
							var panorama = new google.maps.StreetViewPanorama(streetview,
												{
													navigationControl: false,
													enableCloseButton: false,
													addressControl: false,
													linksControl: false,
													visible: true,
													position: marker.getPosition()
												}
											);
						}
					);
				}
			}
		}
	)(marker, txt));
}

/*
* draw the map
*/
function drawMap(latitude, longitude, txt, qty, doCircle, radius, suburbBoundary, showStreetView) 
{
    var latitudeArray = latitude.split(",");
    var longitudeArray = longitude.split(",");
    var txtArray = txt.split(",");
    var qtyArray = qty.split(",");
    var infowindow = new google.maps.InfoWindow();
    var bounds = new google.maps.LatLngBounds();
    var marker;
    var markerImage;
    var qty;
    var i;		 

    var map = new google.maps.Map(document.getElementById('map_canvas'),
            {
                mapTypeId: google.maps.MapTypeId.ROADMAP
            }
        );

    for (i = 0; i < latitudeArray.length; i++) 
	{
		qty = qtyArray[i];
		//marker only upto 99
		if (qty > 99)
		{
			qty = 99;
		}

        if (i == 0 && latitudeArray.length > 1) 
		{
            markerImage = "../images/markers/blue/marker" + qty + ".png";
        }
        else 
		{
            markerImage = "../images/markers/red/marker" + qty + ".png";
        }

        marker = new google.maps.Marker
		(
			{
				position: new google.maps.LatLng(latitudeArray[i], longitudeArray[i]),
				map: map,
				icon: markerImage
			}
        );

        bounds.extend(new google.maps.LatLng(latitudeArray[i], longitudeArray[i]));
        updateMarker(marker, txtArray[i], showStreetView);

    } //end for

	if (doCircle == "1")
	{
		//circle centre is first marker
		drawCircle(map, bounds, new google.maps.LatLng(latitudeArray[0], longitudeArray[0]), radius, 60, "#f33f00", 3, .4, "#fffff0", .4);
	}

    if (suburbBoundary != null && suburbBoundary != "")
	{
		drawSuburbBoundary(map, bounds, suburbBoundary, "#f33f00", 3, .15, "#AFEEEE", .15);
	}

    bestFit(map, bounds, latitudeArray.length)
}

/*
* draw the map for AMP Monitor
*/
function drawMonitorMap(latitude, longitude, txt, color, qty, doCircle, radius, suburbBoundary, showStreetView) 
{
    var latitudeArray = latitude.split(",");
    var longitudeArray = longitude.split(",");
    var txtArray = txt.split(",");
    var qtyArray = qty.split(",");
    var colorArray = color.split(",");
    var infowindow = new google.maps.InfoWindow();
    var bounds = new google.maps.LatLngBounds();
    var marker;
    var markerImage;
    var qty;
    var i;

    var map = new google.maps.Map(document.getElementById('map_canvas'),
            {
                mapTypeId: google.maps.MapTypeId.ROADMAP
            }
        );

    for (i = 0; i < latitudeArray.length; i++) 
	{
		qty = qtyArray[i];
		//marker only upto 99
		if (qty > 99)
		{
			qty = 99;
		}

		if (colorArray[i]=="R") 
		{
			markerImage = "../images/markers/red/marker" + qty + ".png";
		}
		if (colorArray[i]=="Y") 
		{
			markerImage = "../images/markers/orange/marker" + qty + ".png";
		}
		if (colorArray[i]=="G") 
		{
			markerImage = "../images/markers/green/marker" + qty + ".png";
		}
        if (colorArray[i] == "B") 
		{
            markerImage = "../images/markers/blue/marker" + qty + ".png";
        }

        marker = new google.maps.Marker
		(
			{
				position: new google.maps.LatLng(latitudeArray[i], longitudeArray[i]),
				map: map,
				icon: markerImage
			}
        );

        bounds.extend(new google.maps.LatLng(latitudeArray[i], longitudeArray[i]));
        updateMarker(marker, txtArray[i], showStreetView);

    } //end for

    if (doCircle == "1")
	{
		//circle centre is first marker
		drawCircle(map, bounds, new google.maps.LatLng(latitudeArray[0], longitudeArray[0]), radius, 60, "#f33f00", 3, .4, "#fffff0", .4);
	}

    if (suburbBoundary != null && suburbBoundary != "")
	{
		drawSuburbBoundary(map, bounds, suburbBoundary, "#f33f00", 3, .15, "#AFEEEE", .15);
	}

    //yellow //Khaki F0E68C 
    //green //GreenYellow ADFF2F 
    // Red //PeachPuff FFDAB9 
    // blue //PaleTurquoise AFEEEE 					
    bestFit(map, bounds, latitudeArray.length);    
}
