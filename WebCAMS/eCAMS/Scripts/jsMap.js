function bestFit(a, b, e) { 1 < e ? a.fitBounds(b) : (a.setCenter(b.getCenter()), a.setZoom(16)) } function drawCircle(a, b, e, c, f, n, k, h, g, l) { new google.maps.Circle({ strokeColor: n, strokeOpacity: h, strokeWeight: k, fillColor: g, fillOpacity: l, map: a, center: e, radius: 1E3 * c, clickable: !1 }) }
function drawSuburbBoundary(a, b, e, c, f, n, k, h) { b = e.split(":"); e = []; for (var g = 0; g < b.length; g++) { for (var l = b[g].split("|"), d = 0; d < l.length; d++) { var m = new google.maps.LatLng(l[d].split(",")[1], l[d].split(",")[0]); e.push(m) } (new google.maps.Polygon({ paths: e, strokeColor: c, strokeOpacity: n, strokeWeight: f || 2, fillColor: k || c || "#0055ff", fillOpacity: h })).setMap(a) } }
function updateMarker(a, b, e) {
    google.maps.event.addListener(a, "mousedown", function (a, b) {
        return function () {
            var n = document.createElement("DIV"), k = document.createElement("DIV"), h = new google.maps.InfoWindow; k.innerHTML = '<font face="arial" size="2">' + b + "</font>"; n.appendChild(k); if ("1" == e) { var g = document.createElement("DIV"); g.style.width = "200px"; g.style.height = "200px"; n.appendChild(g) } h.setContent(n); h.open(a.getMap(), a); "1" == e && google.maps.event.addListenerOnce(h, "domready", function () {
                new google.maps.StreetViewPanorama(g,
{ navigationControl: !1, enableCloseButton: !1, addressControl: !1, linksControl: !1, visible: !0, position: a.getPosition() })
            })
        } 
    } (a, b))
}
function drawMap(a, b, e, c, f, n, k, h) {
    a = a.split(","); b = b.split(","); e = e.split(","); var g = c.split(","); new google.maps.InfoWindow; var l = new google.maps.LatLngBounds, d, m = new google.maps.Map(document.getElementById("map_canvas"), { mapTypeId: google.maps.MapTypeId.ROADMAP }); for (d = 0; d < a.length; d++) c = g[d], 99 < c && (c = 99), c = 0 == d && 1 < a.length ? "../images/markers/blue/marker" + c + ".png" : "../images/markers/red/marker" + c + ".png", c = new google.maps.Marker({ position: new google.maps.LatLng(a[d],
b[d]), map: m, icon: c
    }), l.extend(new google.maps.LatLng(a[d], b[d])), updateMarker(c, e[d], h); "1" == f && drawCircle(m, l, new google.maps.LatLng(a[0], b[0]), n, 60, "#f33f00", 3, 0.4, "#fffff0", 0.4); null != k && "" != k && drawSuburbBoundary(m, l, k, "#f33f00", 3, 0.15, "#AFEEEE", 0.15); bestFit(m, l, a.length)
}
function drawMonitorMap(a, b, e, c, f, n, k, h, g) {
    a = a.split(","); b = b.split(","); e = e.split(","); var l = f.split(","); c = c.split(","); new google.maps.InfoWindow; var d = new google.maps.LatLngBounds, m, j, p = new google.maps.Map(document.getElementById("map_canvas"), { mapTypeId: google.maps.MapTypeId.ROADMAP }); for (j = 0; j < a.length; j++) f = l[j], 99 < f && (f = 99), "R" == c[j] && (m = "../images/markers/red/marker" + f + ".png"), "Y" == c[j] && (m = "../images/markers/orange/marker" +
f + ".png"), "G" == c[j] && (m = "../images/markers/green/marker" + f + ".png"), "B" == c[j] && (m = "../images/markers/blue/marker" + f + ".png"), f = new google.maps.Marker({ position: new google.maps.LatLng(a[j], b[j]), map: p, icon: m }), d.extend(new google.maps.LatLng(a[j], b[j])), updateMarker(f, e[j], g); "1" == n && drawCircle(p, d, new google.maps.LatLng(a[0], b[0]), k, 60, "#f33f00", 3, 0.4, "#fffff0", 0.4); null != h && "" != h && drawSuburbBoundary(p, d, h, "#f33f00", 3, 0.15, "#AFEEEE",
0.15); bestFit(p, d, a.length)
};