class TodosView < PageView
  CLOSE_POST_DISTANCE = 12.0

  FILTER_CHECKED_SMALL   = :small
  FILTER_CHECKED_NORMAL  = :normal
  FILTER_CHECKED_LONG    = :long
  FILTER_CHECKED_TOURING = :touring
  FILTER_CHECKED_ALL     = [
    FILTER_CHECKED_SMALL,
    FILTER_CHECKED_NORMAL,
    FILTER_CHECKED_LONG,
    FILTER_CHECKED_TOURING,
  ]
  FILTER_CHECKED_STANDARD = [
    FILTER_CHECKED_NORMAL,
    FILTER_CHECKED_LONG,
  ]

  def initialize(@blog : Tremolite::Blog, @todos : Array(TodoRouteEntity), @url : String, @prechecked = [FILTER_CHECKED_NORMAL, FILTER_CHECKED_LONG])
    @image_url = @blog.data_manager.not_nil!["todos.backgrounds"].as(String)
    @title = @blog.data_manager.not_nil!["todos.title"].as(String)
    @subtitle = @blog.data_manager.not_nil!["todos.subtitle"].as(String)
  end

  getter :image_url, :title, :subtitle

  def inner_html
    todo_routes_string = ""
    todo_routes_string += load_html("todo_route/links")

    # prechecked filters
    filter_hash = Hash(String, String).new
    FILTER_CHECKED_ALL.each do |filter_length|
      if @prechecked.includes?(filter_length)
        filter_hash["filter.#{filter_length}.checked"] = "checked"
      else
        filter_hash["filter.#{filter_length}.checked"] = ""
      end
    end
    todo_routes_string += load_html("todo_route/filters", filter_hash)

    @todos.each do |todo_route|
      data = Hash(String, String).new
      data["route.from"] = todo_route.from
      data["route.to"] = todo_route.to

      data["route.url"] = todo_route.url
      data["route.flag_normal"] = todo_route.flag_normal.to_s
      data["route.flag_long"] = todo_route.flag_long.to_s
      data["route.flag_touring"] = todo_route.flag_touring.to_s
      data["route.flag_small"] = todo_route.flag_small.to_s

      if todo_route.transport_from_cost_minutes > 0
        data["route.from_cost"] = "#{todo_route.transport_from_cost_minutes} min = #{todo_route.transport_from_cost_hours.round(1)} h"
        data["route.from_cost_minutes"] = todo_route.transport_from_cost_minutes.to_s
        data["route.from_distance"] = todo_route.from_poi.not_nil!.line_distance_from_home.to_s
        data["route.from_direction_human"] = todo_route.from_poi.not_nil!.direction_from_home_human
      else
        data["route.from_cost"] = ""
        data["route.from_cost_minutes"] = ""
        data["route.from_distance"] = ""
        data["route.from_direction_human"] = ""
      end

      if todo_route.transport_to_cost_minutes > 0
        data["route.to_cost"] = "#{todo_route.transport_to_cost_minutes} min = #{todo_route.transport_to_cost_hours.round(1)} h"
        data["route.to_cost_minutes"] = todo_route.transport_to_cost_minutes.to_s
        data["route.to_distance"] = todo_route.to_poi.not_nil!.line_distance_from_home.to_s
        data["route.to_direction_human"] = todo_route.to_poi.not_nil!.direction_from_home_human
      else
        data["route.to_cost"] = ""
        data["route.to_cost_minutes"] = ""
        data["route.to_distance"] = ""
        data["route.to_direction_human"] = ""
      end

      # closest major poi
      if todo_route.from_poi && todo_route.from_poi.not_nil!.closest_major_name
        data["route.from-major"] = todo_route.from_poi.not_nil!.closest_major_name.not_nil!
      else
        data["route.from-major"] = ""
      end

      if todo_route.to_poi && todo_route.to_poi.not_nil!.closest_major_name
        data["route.to-major"] = todo_route.to_poi.not_nil!.closest_major_name.not_nil!
      else
        data["route.to-major"] = ""
      end

      data["route.distance"] = todo_route.distance.to_i.to_s
      data["route.direction"] = (90 + (1 * todo_route.direction.to_i)).to_s
      data["route.bidirection"] = todo_route.bidirection_human.to_s
      data["route.time_length"] = todo_route.time_length.to_i.to_s
      data["route.total_cost"] = todo_route.total_cost_hours.to_i.to_s

      total_cost_explained = ""
      if todo_route.transport_from_cost_minutes > 0 || todo_route.transport_to_cost_minutes > 0
        total_cost_explained += " = "
        if todo_route.transport_from_cost_minutes > 0
          total_cost_explained += "#{todo_route.transport_from_cost_minutes}min + "
        end
        total_cost_explained += "#{todo_route.time_length_minutes.to_i}min"
        if todo_route.transport_to_cost_minutes > 0
          total_cost_explained += " + #{todo_route.transport_to_cost_minutes}min"
        end
      end
      data["route.total_cost_explained"] = total_cost_explained

      data["route.time_length_percentage"] = todo_route.time_length_percentage.to_i.to_s
      data["route.straight_line_length"] = todo_route.straight_line_length.to_i.to_s
      data["route.distance_to_straigh_percentage"] = todo_route.distance_to_straigh_percentage.to_i.to_s
      data["route.center_point_distance_to_home"] = todo_route.distance_center_point_to_home.to_i.to_s
      data["route.time_cost_per_distance_center_km_in_seconds"] = todo_route.time_cost_per_distance_center_km_in_seconds.to_i.to_s

      # with accommodation
      data["route.total_cost_external_accommodation"] = "N/A "
      data["route.total_cost_external_accommodation_explained"] = ""
      data["route.time_length_external_accommodation_percentage"] = "N/A "
      data["partial.accommodation"] = ""
      # only if this is set
      if todo_route.train_return_time_cost
        data["route.total_cost_external_accommodation"] = todo_route.total_cost_external_accommodation.not_nil!.round(1).to_s
        data["route.total_cost_external_accommodation_explained"] = "#{todo_route.train_return_time_cost_minutes}min + #{todo_route.time_length_minutes}min"
        data["route.time_length_external_accommodation_percentage"] = todo_route.time_length_external_accommodation_percentage.to_i.to_s
        # render partial
        data["partial.accommodation"] = load_html("todo_route/item_accommodation", data)
      end

      if todo_route.through.size > 0
        # show transport cost for intermediate points if is defined as TransportPoiEntity
        transport_pois = @blog.data_manager.not_nil!.transport_pois.not_nil!
        todo_route_string = todo_route.through.map { |t|
          ts = transport_pois.select { |p| p.name.strip == t.strip }
          if ts.size > 0
            "#{t} (<strong>#{ts[0].time_cost}min</strong>)"
          else
            t
          end
        }.join(", ")

        data["partial.through"] = load_html("todo_route/item_through", {"route.through" => todo_route_string})
      else
        data["partial.through"] = ""
      end

      # related (close distance) posts
      post_links = Array(String).new

      @blog.post_collection.posts.each do |p|
        if todo_route.from_poi
          d = p.closest_distance_to_point(lat: todo_route.from_poi.not_nil!.lat, lon: todo_route.from_poi.not_nil!.lon)
          if d && d.not_nil! < CLOSE_POST_DISTANCE
            post_links << "<a href=\"" + p.url + "\">" + p.date + "</a>"
          end
        end
      end

      data["partial.post_links"] = ""
      if post_links.size > 0
        data["partial.post_links"] = load_html("todo_route/item_posts", {"route.posts" => post_links.join(", "), "route.posts_distance" => CLOSE_POST_DISTANCE.to_i.to_s})
      end

      todo_routes_string += load_html("todo_route/item", data)
      todo_routes_string += "\n"
    end

    todo_routes_string += load_html("todo_route/js")
    return todo_routes_string
  end
end
