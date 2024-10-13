module ApplicationHelper
  def flash_style(type)
    case type
    when "notice" then "bg-green-100 border-green-400 text-green-700"
    when "alert" then "bg-red-100 border-red-400 text-red-700"
    end
  end
end
