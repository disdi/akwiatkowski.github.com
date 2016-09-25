// Generated by CoffeeScript 1.10.0
var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

this.BlogSummary = (function() {
  function BlogSummary() {
    this.startSummary = bind(this.startSummary, this);
  }

  BlogSummary.prototype.start = function() {
    return $.ajax({
      url: "/payload.json",
      success: (function(_this) {
        return function(data) {
          _this.data = data;
          _this.startSummary();
          return _this.calcStats();
        };
      })(this)
    });
  };

  BlogSummary.prototype.startSummary = function() {
    $("#by-land").click((function(_this) {
      return function() {
        _this.startSummaryByLand();
        return false;
      };
    })(this));
    $("#by-town").click((function(_this) {
      return function() {
        _this.startSummaryByTown();
        return false;
      };
    })(this));
    return $("#by-time").click((function(_this) {
      return function() {
        _this.startSummaryByTime();
        return false;
      };
    })(this));
  };

  BlogSummary.prototype.calcStats = function() {
    var all_count, done_count, i, is_done, len, post, ref;
    done_count = 0;
    all_count = 0;
    ref = this.data["posts"];
    for (i = 0, len = ref.length; i < len; i++) {
      post = ref[i];
      is_done = true;
      if (post.tags.indexOf("todo") >= 0) {
        is_done = false;
      }
      if (is_done) {
        done_count++;
      }
      all_count++;
    }
    $("#stats-count").html(all_count);
    $("#stats-done-count").html(done_count);
    return $("#stats-done-percent").html(parseInt(100 * done_count / all_count));
  };

  BlogSummary.prototype.startSummaryByTown = function() {
    var i, len, main_object, post, posts_container, ref, results, town, town_object, voivodeship, voivodeship_container, voivodeship_object;
    $("#content").html("");
    main_object = $("<ul>", {
      id: "town-tree",
      "class": "summary"
    }).appendTo("#content");
    ref = this.data["towns"];
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      voivodeship = ref[i];
      if (voivodeship.type === "voivodeship") {
        voivodeship_object = $("<li>", {
          id: voivodeship.slug,
          "class": "summary-voivodeship"
        }).appendTo(main_object);
        $("<span>", {
          text: voivodeship.name,
          title: voivodeship.name
        }).appendTo(voivodeship_object);
        voivodeship_container = $("<ul>", {
          id: voivodeship.slug,
          "class": "summary-towns-container"
        }).appendTo(voivodeship_object);
        results.push((function() {
          var j, len1, ref1, results1;
          ref1 = this.data["towns"];
          results1 = [];
          for (j = 0, len1 = ref1.length; j < len1; j++) {
            town = ref1[j];
            console.log(town, voivodeship);
            if (town.voivodeship === voivodeship.slug) {
              town_object = $("<li>", {
                id: town.slug,
                "class": "summary-town"
              }).appendTo(voivodeship_container);
              $("<a>", {
                text: town.name,
                title: town.name,
                href: town.url
              }).appendTo(town_object);
              posts_container = $("<ul>", {
                "class": "summary-posts-container"
              }).appendTo(town_object);
              results1.push((function() {
                var k, len2, ref2, results2;
                ref2 = this.data["posts"];
                results2 = [];
                for (k = 0, len2 = ref2.length; k < len2; k++) {
                  post = ref2[k];
                  if (post.towns.indexOf(town.slug) >= 0) {
                    results2.push(this.insertPost(post, posts_container));
                  } else {
                    results2.push(void 0);
                  }
                }
                return results2;
              }).call(this));
            } else {
              results1.push(void 0);
            }
          }
          return results1;
        }).call(this));
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

  BlogSummary.prototype.startSummaryByTime = function() {
    var i, len, main_object, month_id, month_li, post, ref, results, year_id, year_li;
    $("#content").html("");
    main_object = $("<ul>", {
      id: "time-tree",
      "class": "summary"
    }).appendTo("#content");
    ref = this.data["posts"];
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      post = ref[i];
      year_id = "time-" + post.year;
      month_id = "time-" + post.year + "_" + post.month;
      if ($("#" + year_id).length === 0) {
        year_li = $("<li>", {
          "class": "summary-time-year"
        }).appendTo(main_object);
        $("<span>", {
          text: post.year,
          title: post.year
        }).appendTo(year_li);
        $("<ul>", {
          id: "time-" + post.year,
          "class": "summary-time-year-container"
        }).appendTo(year_li);
      }
      if ($("#" + month_id).length === 0) {
        month_li = $("<li>", {
          "class": "summary-time-month"
        }).appendTo($("#" + year_id));
        $("<span>", {
          text: post.month,
          title: post.month
        }).appendTo(month_li);
        $("<ul>", {
          id: month_id,
          "class": "summary-time-month-container"
        }).appendTo(month_li);
      }
      results.push(this.insertPost(post, $("#" + month_id)));
    }
    return results;
  };

  BlogSummary.prototype.insertPost = function(post, posts_container) {
    var is_done, post_element;
    is_done = true;
    if (post.tags.indexOf("todo") >= 0) {
      is_done = false;
    }
    post_element = $("<li>", {
      "class": "summary-post"
    }).appendTo(posts_container);
    if (is_done === false) {
      post_element.addClass("summary-post-todo");
    }
    return $("<a>", {
      text: post.date + " - " + post.title,
      title: post.date + " - " + post.title,
      href: post.url
    }).appendTo(post_element);
  };

  BlogSummary.prototype.startSummaryByLand = function() {
    var i, land, land_object, land_type, land_type_container, land_type_object, len, main_object, post, posts_container, ref, results;
    $("#content").html("");
    main_object = $("<ul>", {
      id: "land-tree",
      "class": "summary"
    }).appendTo("#content");
    ref = this.data["land_types"];
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      land_type = ref[i];
      land_type_object = $("<li>", {
        id: land_type.slug,
        "class": "summary-land-type"
      }).appendTo("#land-tree");
      $("<span>", {
        text: land_type.name,
        title: land_type.name
      }).appendTo(land_type_object);
      land_type_container = $("<ul>", {
        id: land_type.slug,
        "class": "summary-lands-container"
      }).appendTo(land_type_object);
      results.push((function() {
        var j, len1, ref1, results1;
        ref1 = this.data["lands"];
        results1 = [];
        for (j = 0, len1 = ref1.length; j < len1; j++) {
          land = ref1[j];
          if (land.type === land_type.slug) {
            land_object = $("<li>", {
              id: land.slug,
              "class": "summary-land"
            }).appendTo(land_type_container);
            $("<a>", {
              text: land.name,
              title: land.name,
              href: land.url
            }).appendTo(land_object);
            posts_container = $("<ul>", {
              "class": "summary-posts-container"
            }).appendTo(land_object);
            results1.push((function() {
              var k, len2, ref2, results2;
              ref2 = this.data["posts"];
              results2 = [];
              for (k = 0, len2 = ref2.length; k < len2; k++) {
                post = ref2[k];
                if (post.lands.indexOf(land.slug) >= 0) {
                  results2.push(this.insertPost(post, posts_container));
                } else {
                  results2.push(void 0);
                }
              }
              return results2;
            }).call(this));
          } else {
            results1.push(void 0);
          }
        }
        return results1;
      }).call(this));
    }
    return results;
  };

  return BlogSummary;

})();
