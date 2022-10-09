module ApplicationHelper

  def homepage_progress_bar(stats)
    bar = content_tag(:div, class: 'bar') do
      content_tag(:div, nil, class: 'uploaded', style: "width: #{100.0*stats[:uploaded]/stats[:found]}%;") +
      content_tag(:div, nil, class: 'listened', style: "width: #{100.0*stats[:listened]/stats[:found]}%;")
    end
    legend = content_tag(:div, class: 'legend') do
      "Poslušano #{ number_with_delimiter stats[:listened] } /
       Sakupljeno #{ number_with_delimiter stats[:uploaded] } /
       Pronađeno #{ number_with_delimiter stats[:found] }"
     end

     (bar + legend).html_safe
  end

  def album_row_class(album)
    [
      "album-row",
      current_user&.upload_access? && !album.uploaded? ? "missing" : nil,
      current_user && album.rated_by?(current_user.id) ? "listened" : nil,
    ]
  end

  def decade_options
    [["Sva", nil], "50", "60", "70", "80", "90"]
  end

  def empty_gif
    "data:image/gif;base64,R0lGODlhAQABAIAAAP///wAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw=="
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    direction = (column == params[:sort] && params[:direction] == "asc") ? "desc" : "asc"
    sort_params = params.except(:page).merge(sort: column, direction: direction).to_unsafe_h
    link_to title, sort_params
  end
end
