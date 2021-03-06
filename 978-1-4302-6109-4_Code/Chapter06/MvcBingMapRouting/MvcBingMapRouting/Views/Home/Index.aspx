﻿<%@ Page Language="C#" Inherits="System.Web.Mvc.ViewPage<List<MvcBingMapRouting.Models.GeoLocation>>" %>


<!DOCTYPE html>

<html>
<head>
    <title>Find directions</title>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <script type="text/javascript" src="http://ecn.dev.virtualearth.net/mapcontrol/mapcontrol.ashx?v=7.0"></script>
    <script type="text/javascript">
        var map = null;
        var end;
        var start;
        
        function getMap() {
            map = new Microsoft.Maps.Map(document.getElementById('myMap'), { credentials: 'At_LKBdN_d_G9Y6N53J-GtmMY8ZB-1iEc8hMlwoq6tlNldu-nkGkDPMnaye_a6XT'});
        }
  

        function callRouteService(credentials) {          
            var routeRequest = 'http://dev.virtualearth.net/REST/v1/Routes?wp.0=' + start + '&wp.1=' + end + '&routePathOutput=Points&output=json&jsonp=routeCallback&key=' + credentials;
            var mapscript = document.createElement('script');
            mapscript.type = 'text/javascript';
            mapscript.src = routeRequest;
            document.getElementById('myMap').appendChild(mapscript);
        }

        function routeCallback(result) {
            var output = document.getElementById("output");
            if (output) {
                while (output.hasChildNodes()) {
                    output.removeChild(output.lastChild);
                }
                var resultsHeader = document.createElement("h5");
                var resultsList = document.createElement("ol");
                output.appendChild(resultsHeader);
                output.appendChild(resultsList);
            }

            if (result && result.resourceSets && result.resourceSets.length > 0 && result.resourceSets[0].resources && result.resourceSets[0].resources.length > 0) {
                resultsHeader.innerHTML = "Bing Maps REST Route API  <br/>  Route from " + result.resourceSets[0].resources[0].routeLegs[0].startLocation.name + " to " + result.resourceSets[0].resources[0].routeLegs[0].endLocation.name;
                var resultsListItem = null;

                for (var i = 0; i < result.resourceSets[0].resources[0].routeLegs[0].itineraryItems.length; ++i) {
                    resultsListItem = document.createElement("li");
                    resultsList.appendChild(resultsListItem);
                    resultStr = result.resourceSets[0].resources[0].routeLegs[0].itineraryItems[i].instruction.text;
                    resultsListItem.innerHTML = resultStr;
                }
                var bbox = result.resourceSets[0].resources[0].bbox;
                var viewBoundaries = Microsoft.Maps.LocationRect.fromLocations(new Microsoft.Maps.Location(bbox[0], bbox[1]), new Microsoft.Maps.Location(bbox[2], bbox[3]));
                map.setView({ bounds: viewBoundaries });
                var routeline = result.resourceSets[0].resources[0].routePath.line; var routepoints = new Array();
                for (var i = 0; i < routeline.coordinates.length; i++) {
                    routepoints[i] = new Microsoft.Maps.Location(routeline.coordinates[i][0], routeline.coordinates[i][1]);
                }
                var routeshape = new Microsoft.Maps.Polyline(routepoints, { strokeColor: new Microsoft.Maps.Color(200, 0, 0, 200) });

                var startPushpinOptions = { anchor: new Microsoft.Maps.Point(10, 32) };
                var startPin = new Microsoft.Maps.Pushpin(new Microsoft.Maps.Location(routeline.coordinates[0][0], routeline.coordinates[0][1]), startPushpinOptions);

                var endPushpinOptions = { anchor: new Microsoft.Maps.Point(10, 32) };
                var endPin = new Microsoft.Maps.Pushpin(new Microsoft.Maps.Location(routeline.coordinates[routeline.coordinates.length - 1][0], routeline.coordinates[routeline.coordinates.length - 1][1]), endPushpinOptions);
                map.entities.push(startPin);
                map.entities.push(endPin);
                map.entities.push(routeshape);
            }

            else {
                if (typeof (result.errorDetails) != 'undefined') {
                    resultsHeader.innerHTML = result.errorDetails[0];
                }
                alert("No Route found");
            }
        }
          
        function getDirections() {
            start = '<%=Model[0].LocationName%>, ' + '<%=Model[0].City%>'; end = '<%=Model[1].LocationName%>, ' + '<%=Model[1].City%>';
              map.getCredentials(callRouteService);
          }
          

    </script>
</head>
<body onload="getMap();">
    <div id='myMap' style="position: relative; width: 1000px; height: 500px;"></div>
    <div>
        <input type="button" value="GetDirections" onclick="getDirections();" />
    </div>
    <div id="output"></div>

</body>
</html>
