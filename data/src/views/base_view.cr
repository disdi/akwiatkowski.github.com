class BaseView < Tremolite::Views::BaseView
  def initialize(@blog : Tremolite::Blog, @url : String)
  end

  getter :url

  def to_html
    return top_html +
      head_open_html +
      head_title_html +
      seo_html +
      open_graph_html +
      tracking_html +
      head_close_html +
      open_body_html +
      nav_html +
      content +
      footer_html +
      close_body_html +
      close_html_html
  end

  def top_html
    # no parameters
    return load_html("include/top")
  end

  def head_open_html
    # no parameters
    return load_html("include/head_open")
  end

  def head_title_html
    return "<title>#{head_title}</title>\n"
  end

  def head_title
    # allow validating null titles later
    return "" if title == ""
    return "#{title} - #{site_title}"
  end

  def site_title
    @blog.data_manager.not_nil!["site.title"]
  end

  def site_desc
    @blog.data_manager.not_nil!["site.desc"]
  end

  def site_url
    @blog.data_manager.not_nil!["site.url"]
  end

  def title
    return ""
  end

  def subtitle
    return ""
  end

  def seo_html
    return ""
  end

  def image_url
    return ""
  end

  def open_graph_html
    s = ""
    if image_url != ""
      h = Hash(String, String).new
      h["ol.image"] = site_url + image_url
      s += load_html("include/open_graph_image", h)
    end

    return s
  end

  def tracking_html
    # no parameters
    return load_html("include/tracking")
  end

  def head_close_html
    "</head>\n"
  end

  def open_body_html
    "<body>\n"
  end

  def close_body_html
    "</body>\n"
  end

  def close_html_html
    "</html>\n"
  end

  def nav_html
    # parametrized
    h = Hash(String, String).new
    h["site.title"] = @blog.data_manager.not_nil!["site.title"] if @blog.data_manager.not_nil!["site.title"]?

    return load_html("include/nav", h)
  end

  def content
    return ""
  end

  def footer_html
    h = Hash(String, String).new
    h["site.title"] = @blog.data_manager.not_nil!["site.title"] if @blog.data_manager.not_nil!["site.title"]?
    h["year"] = Time.local.year.to_s

    return load_html("include/footer", h)
  end

  def render_posts_preview(posts : Array(Tremolite::Post))
    content = ""

    posts.each_with_index do |post, i|
      ph = Hash(String, String).new
      ph["post.index_prefix"] = "#{i + 1}. "
      ph["post.url"] = post.url
      ph["post.title"] = post.title
      ph["post.subtitle"] = post.subtitle
      ph["post.date"] = post.date
      ph["post.author"] = post.author

      if post.todo?
        ph["post.preview-klass"] = "post-todo"
      else
        ph["post.preview-klass"] = ""
      end

      ph["post.thumb_image_url"] = post.big_thumb_image_url.not_nil!

      content += load_html("post/preview", ph)
      content += "\n"
    end

    return content
  end
end

# a little dirty hax
require "./helpers/seo_helper"
