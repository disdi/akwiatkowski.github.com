// Generated by CoffeeScript 1.10.0
this.BlogMap = (function() {
  function BlogMap() {}

  BlogMap.prototype.start = function() {
    return $.ajax({
      url: "/payload.json",
      success: (function(_this) {
        return function(data) {
          _this.data = data;
          _this.initializeLayout();
          return _this.startMap();
        };
      })(this)
    });
  };

  BlogMap.prototype.initializeLayout = function() {
    var clientHeight, containerWidth, mapHeight, topPosition;
    clientHeight = document.body.clientHeight;
    containerWidth = $(".container").width();
    topPosition = $("#map-container").position().top;
    mapHeight = clientHeight - topPosition - 200;
    if (mapHeight < 300) {
      mapHeight = 300;
    }
    $('.intro-header').height(clientHeight);
    $("#map-container").width(containerWidth);
    $("#content").height(mapHeight);
    return $("#content").width(containerWidth);
  };

  BlogMap.prototype.startMap = function() {
    var c, circleLayer, coords, ct, feature, geojsonObject, i, interaction, j, len, len1, lineLayerCycle, lineLayerHike, lineLayerRegular, map, post, ref, ref1, sourceCircles, sourceLinesCycle, sourceLinesHike, sourceLinesRegular, styleCircle, styleLineCycle, styleLineHike, styleLineRegular;
    styleLineRegular = new ol.style.Style({
      stroke: new ol.style.Stroke({
        color: "#008800",
        width: 3
      }),
      fill: new ol.style.Fill({
        color: "rgba(255, 0, 0, 0.2)"
      })
    });
    styleLineHike = new ol.style.Style({
      stroke: new ol.style.Stroke({
        color: "#ff9900",
        width: 3
      }),
      fill: new ol.style.Fill({
        color: "rgba(255, 0, 0, 0.2)"
      })
    });
    styleLineCycle = new ol.style.Style({
      stroke: new ol.style.Stroke({
        color: "#0055FF",
        width: 3
      }),
      fill: new ol.style.Fill({
        color: "rgba(255, 0, 0, 0.2)"
      })
    });
    styleCircle = new ol.style.Style({
      stroke: new ol.style.Stroke({
        color: "#FF0000",
        width: 3
      }),
      fill: new ol.style.Fill({
        color: "rgba(255, 0, 0, 0.2)"
      })
    });
    geojsonObject = {};
    sourceCircles = new ol.source.Vector({
      features: (new ol.format.GeoJSON()).readFeatures(geojsonObject)
    });
    sourceLinesCycle = new ol.source.Vector({
      features: (new ol.format.GeoJSON()).readFeatures(geojsonObject)
    });
    sourceLinesHike = new ol.source.Vector({
      features: (new ol.format.GeoJSON()).readFeatures(geojsonObject)
    });
    sourceLinesRegular = new ol.source.Vector({
      features: (new ol.format.GeoJSON()).readFeatures(geojsonObject)
    });
    ref = this.data["posts"];
    for (i = 0, len = ref.length; i < len; i++) {
      post = ref[i];
      if (false) {
        sourceCircles.addFeature(new ol.Feature(new ol.geom.Circle(ol.proj.transform([post["coords-circle"][1], post["coords-circle"][0]], 'EPSG:4326', 'EPSG:3857'), parseFloat(post["range"]) * 1000.0)));
      }
      if (false) {
        coords = [ol.proj.transform([post["coords-from"][1], post["coords-from"][0]], 'EPSG:4326', 'EPSG:3857'), ol.proj.transform([post["coords-to"][1], post["coords-to"][0]], 'EPSG:4326', 'EPSG:3857')];
        sourceLines.addFeature(new ol.Feature(new ol.geom.LineString(coords)));
      }
      if (post["coords-multi"]) {
        coords = [];
        ref1 = post["coords-multi"];
        for (j = 0, len1 = ref1.length; j < len1; j++) {
          c = ref1[j];
          ct = ol.proj.transform([c[1], c[0]], 'EPSG:4326', 'EPSG:3857');
          coords.push(ct);
        }
        feature = new ol.Feature(new ol.geom.LineString(coords));
        feature.set("post-date", post["date"]);
        feature.set("post-url", post["url"]);
        feature.set("post-title", post["title"]);
        if (post.tags.indexOf("hike") >= 0) {
          sourceLinesHike.addFeature(feature);
        } else if (post.tags.indexOf("bicycle") >= 0) {
          sourceLinesCycle.addFeature(feature);
        } else {
          sourceLinesRegular.addFeature(feature);
        }
      }
    }
    circleLayer = new ol.layer.Vector({
      source: sourceCircles,
      style: styleCircle
    });
    lineLayerCycle = new ol.layer.Vector({
      source: sourceLinesCycle,
      style: styleLineCycle
    });
    lineLayerHike = new ol.layer.Vector({
      source: sourceLinesHike,
      style: styleLineHike
    });
    lineLayerRegular = new ol.layer.Vector({
      source: sourceLinesRegular,
      style: styleLineRegular
    });
    map = new ol.Map({
      target: "content",
      projection: "EPSG:4326",
      layers: [
        new ol.layer.Tile({
          source: new ol.source.OSM()
        }), circleLayer, lineLayerRegular, lineLayerHike, lineLayerCycle
      ],
      view: new ol.View({
        center: ol.proj.transform([19.4553, 51.7768], 'EPSG:4326', 'EPSG:3857'),
        zoom: 6
      })
    });
    interaction = new ol.interaction.Select();
    interaction.getFeatures().on("add", (function(_this) {
      return function(e) {
        var img, k, l, last_p, len2, len3, new_image, obj, p, ref2, ref3, results;
        last_p = null;
        ref2 = e.target.b;
        for (k = 0, len2 = ref2.length; k < len2; k++) {
          obj = ref2[k];
          p = obj.B;
          last_p = p;
          $("#links").html("");
          $("<a>", {
            text: p["post-date"] + " - " + p["post-title"],
            title: p["post-date"] + " - " + p["post-title"],
            href: p["post-url"]
          }).appendTo("#links");
        }
        ref3 = _this.data["posts"];
        results = [];
        for (l = 0, len3 = ref3.length; l < len3; l++) {
          post = ref3[l];
          if (post.url === last_p["post-url"]) {
            new_image = post["header-ext-img"];
            if (new_image) {
              img = new Image();
              img.onload = function() {
                $('#background2').css('background-image', $('#background1').css('background-image'));
                $('#background2').show();
                $('#background1').css('background-image', "url(" + new_image + ")");
                $("#background2").fadeOut(1500, function() {});
                return console.log("done");
              };
            }
            results.push(img.src = new_image);
          } else {
            results.push(void 0);
          }
        }
        return results;
      };
    })(this));
    return map.addInteraction(interaction);
  };

  return BlogMap;

})();
