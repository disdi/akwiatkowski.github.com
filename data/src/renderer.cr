require "./views/base_view"
require "./views/page_view"

require "./views/home_view"
require "./views/paginated_post_list_view"
require "./views/map_view"
require "./views/planner_view"
require "./views/tag_view"
require "./views/town_view"
require "./views/land_view"
require "./views/post_view"
require "./views/summary_view"
require "./views/markdown_page_view"
require "./views/todos_view"
require "./views/pois_view"
require "./views/towns_index_view"
require "./views/lands_index_view"

require "./views/payload_json_generator"
require "./views/rss_generator"
require "./views/atom_generator"

class Tremolite::Renderer
  def render_all
    render_index
    render_posts
    render_paginated_list
    render_map
    render_planner
    render_tags_pages
    render_lands_pages
    render_towns_pages
    render_todo_routes
    render_pois
    render_towns_index
    render_lands_index

    render_more_page
    render_about_page
    render_summary_page

    render_payload_json
    render_rss
    render_atom
  end

  def render_index
    view = HomeView.new(blog: @blog, url: "/")
    write_output(view.url, view.to_html)
  end

  def render_paginated_list
    per_page = PaginatedPostListView::PER_PAGE
    i = 0
    total_count = blog.post_collection.posts.size

    posts_per_pages = Array(Array(Tremolite::Post)).new

    while i < total_count
      from_idx = i
      to_idx = i + per_page - 1

      posts = blog.post_collection.posts_from_latest[from_idx..to_idx]
      posts_per_pages << posts

      i += per_page
    end

    posts_per_pages.each_with_index do |posts, i|
      page_number = i + 1
      url = "/list/page/#{page_number}"
      url = "/list/" if page_number == 1

      # render and save
      view = PaginatedPostListView.new(
        blog: @blog,
        url: url,
        posts: posts,
        page: page_number,
        count: posts_per_pages.size
      )

      write_output(url, view.to_html)
    end

    @logger.info("Renderer: Rendered paginated list")
  end

  def render_map
    view = MapView.new(blog: @blog, url: "/map")
    write_output(view.url, view.to_html)
  end

  def render_planner
    view = PlannerView.new(blog: @blog, url: "/planner")
    write_output(view.url, view.to_html)
  end

  def render_todo_routes
    todos_all = @blog.data_manager.not_nil!.todo_routes.not_nil!

    # all
    todos = todos_all.sort { |a, b| a.distance <=> b.distance }
    view = TodosView.new(blog: @blog, todos: todos, url: "/todos/")
    write_output(view.url, view.to_html)

    # close - within 150 minutes of train
    todos = todos_all.select { |t| t.close? }.sort { |a, b| a.distance <=> b.distance }
    view = TodosView.new(blog: @blog, todos: todos, url: "/todos/close")
    write_output(view.url, view.to_html)

    # full_day - 150-270 (2.5-4.5h) minutes of train
    todos = todos_all.select { |t| t.full_day? }.sort { |a, b| a.distance <=> b.distance }
    view = TodosView.new(blog: @blog, todos: todos, url: "/todos/full_day")
    write_output(view.url, view.to_html)

    # external - >270 (4.5h) minutes of train
    todos = todos_all.select { |t| t.external? }.sort { |a, b| a.distance <=> b.distance }
    view = TodosView.new(blog: @blog, todos: todos, url: "/todos/external")
    write_output(view.url, view.to_html)

    # touring - longer than 140km
    todos = todos_all.select { |t| t.touring? }.sort { |a, b| a.distance <=> b.distance }
    view = TodosView.new(blog: @blog, todos: todos, url: "/todos/touring")
    write_output(view.url, view.to_html)

    # order by "from"
    todos = todos_all.sort { |a, b| a.from <=> b.from }
    view = TodosView.new(blog: @blog, todos: todos, url: "/todos/order_by/from")
    write_output(view.url, view.to_html)

    # order by "transport_total_cost_minutes"
    todos = todos_all.sort { |a, b| a.transport_total_cost_minutes <=> b.transport_total_cost_minutes }
    view = TodosView.new(blog: @blog, todos: todos, url: "/todos/order_by/transport_cost")
    write_output(view.url, view.to_html)

    # notes from markdown
    view = MarkdownPageView.new(
      blog: @blog,
      url: "/todos/notes",
      file: "todo_notes",
      image_path: @blog.data_manager.not_nil!["todos.backgrounds"],
      title: @blog.data_manager.not_nil!["todos.title"],
      subtitle: @blog.data_manager.not_nil!["todos.subtitle"]
    )
    write_output(view.url, view.to_html)
  end

  def render_payload_json
    view = PayloadJsonGenerator.new(blog: @blog, url: "/payload.json")
    write_output(view.url, view.to_json)
  end

  def render_rss
    posts = @blog.post_collection.posts
    view = RssGenerator.new(
      blog: @blog,
      posts: posts,
      url: "/feed.xml",
      site_title: @blog.data_manager.not_nil!["site.title"],
      site_url: @blog.data_manager.not_nil!["site.url"],
      site_desc: @blog.data_manager.not_nil!["site.desc"],
      site_webmaster: @blog.data_manager.not_nil!["site.email"],
      site_language: "pl"
    )

    write_output(view.url, view.to_xml)
  end

  def render_atom
    posts = @blog.post_collection.posts
    view = AtomGenerator.new(
      blog: @blog,
      posts: posts,
      url: "/feed_atom.xml",
      site_title: @blog.data_manager.not_nil!["site.title"],
      site_url: @blog.data_manager.not_nil!["site.url"],
      site_desc: @blog.data_manager.not_nil!["site.desc"],
      site_webmaster: @blog.data_manager.not_nil!["site.email"],
      author_name: @blog.data_manager.not_nil!["site.author"],
      site_guid: Crypto::MD5.hex_digest(@blog.data_manager.not_nil!["site.title"]).to_guid,
      site_language: "pl"
    )

    write_output(view.url, view.to_xml)
  end

  def render_tags_pages
    blog.data_manager.not_nil!.tags.not_nil!.each do |tag|
      download_image_if_needed(local: tag.image_url, remote: tag.header_ext_img)
      view = TagView.new(blog: @blog, tag: tag)
      write_output(view.url, view.to_html)
    end
    @logger.info("Renderer: Tags finished")
  end

  def render_lands_pages
    blog.data_manager.not_nil!.lands.not_nil!.each do |land|
      download_image_if_needed(local: land.image_url, remote: land.header_ext_img)
      view = LandView.new(blog: @blog, land: land)
      write_output(view.url, view.to_html)
    end
    @logger.info("Renderer: Lands finished")
  end

  def render_towns_pages
    blog.data_manager.not_nil!.towns.not_nil!.each do |town|
      download_image_if_needed(local: town.image_url, remote: town.header_ext_img)
      view = TownView.new(blog: @blog, town: town)
      write_output(view.url, view.to_html)
    end
    @logger.info("Renderer: Towns finished")
  end

  def render_posts
    blog.post_collection.posts.each do |post|
      render_post(post)
    end
    @logger.info("Renderer: Posts finished")
  end

  def render_post(post : Tremolite::Post)
    view = PostView.new(blog: @blog, post: post)
    write_output(view.url, view.to_html)
  end

  def render_more_page
    view = MarkdownPageView.new(
      blog: @blog,
      url: "/more",
      file: "more",
      image_path: @blog.data_manager.not_nil!["more.backgrounds"],
      title: @blog.data_manager.not_nil!["more.title"],
      subtitle: @blog.data_manager.not_nil!["more.subtitle"]
    )
    write_output(view.url, view.to_html)
  end

  def render_about_page
    view = MarkdownPageView.new(
      blog: @blog,
      url: "/about",
      file: "about",
      image_path: @blog.data_manager.not_nil!["about.backgrounds"],
      title: @blog.data_manager.not_nil!["about.title"],
      subtitle: @blog.data_manager.not_nil!["about.subtitle"]
    )
    write_output(view.url, view.to_html)
  end

  def render_summary_page
    view = SummaryView.new(blog: @blog, url: "/summary")
    write_output(view.url, view.to_html)
  end

  def render_pois
    view = PoisView.new(blog: @blog, url: "/pois")
    write_output(view.url, view.to_html)
  end

  def render_towns_index
    view = TownsIndexView.new(blog: @blog, url: "/towns")
    write_output(view.url, view.to_html)
  end

  def render_lands_index
    view = LandsIndexView.new(blog: @blog, url: "/lands")
    write_output(view.url, view.to_html)
  end
end