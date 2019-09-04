module TableHelper
  def table_format(key, value, klass)
    value.tap do |v|
      break v.join(", ") if v.is_a? Array
      break v.in_time_zone('Central Time (US & Canada)').strftime("%e %b %y %I:%M %p") if v.is_a? Time

      if v.is_a?(Hash) && key == "episodes"
        htmlString = v.inject([]) {|memo, (k, v)|
          memo << "<a href='/episodes/"+v.to_s+"'>"+k+"</a>"
        }.join(", ")

        break raw(htmlString)
      end

      if key == "name"
        if klass == "Guest"
          break raw("<a href='/hosts/"+Guest.find_by(name: v)._id+"'>"+v+"</a>")
        elsif klass = "Host"
          break raw("<a href='/hosts/"+Host.find_by(name: v)._id+"'>"+v+"</a>")
        end
      end
    end
  end
end
