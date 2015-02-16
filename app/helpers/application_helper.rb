module ApplicationHelper
  
  def decade_options
    [["Sva", nil], "50", "60", "70", "80", "90"]
  end
  
  def sortable(column, title = nil)
    title ||= column.titleize
    direction = (column == params[:sort] && params[:direction] == "asc") ? "desc" : "asc"
    sort_params = params.except(:page).merge(sort: column, direction: direction)
    link_to title, sort_params
  end

end
