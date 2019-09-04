module EpisodesHelper

  # Returns an html_safe, comma seperated list of links to
  # related host profiles for this episode_id
  # or the save that crew link if every host is in this episode
  def episode_hosts(episode)
    unless episode.hosts.empty?
      episode.hosts.tap { |hosts|
        all_hosts = Host.all.inject([]) {|memo, host| memo << host._id }.sort
        if all_hosts.sort == hosts.sort
          hosts[0] = "<a href='/hosts'>
                        <u>The Save That Crew</u>
                      </a>"+ (params[:action] == 'edit' ? "<i class='fas fa-times padded-i remove-crew'></i>" : "")
          hosts.slice!(1, hosts.length-1)
        else
          idx = 0

          hosts.map! do |id|
            idx += 1
            
            ""+(idx-1 == hosts.length-1 && hosts.length > 1 ? "and " : "")+"<a href='/hosts/"+id+"'>
              <u>"+Host.find(id).try(:name)+""+(hosts.length > 2 && idx-1 != hosts.length-1 ? "," : "")+"</u>
            </a>" + (params[:action] == 'edit' ? "<i class='fas fa-times padded-i remove-host' data-host-id="+id+"></i>" : "")
          end
        end
      }.join.html_safe
    end
  end

  def episode_guests(episode)
    unless episode.guests.empty?
      episode.guests.tap { |guests|
        idx = 0

        guests.map! do |id|
          idx += 1
          
          ""+(idx-1 == guests.length-1 && guests.length > 1 ? "and " : "")+"<a href='/guests/"+id+"'>
            <u>"+Guest.find(id).try(:name)+""+(guests.length > 2 && idx-1 != guests.length-1 ? "," : "")+"</u>
          </a>" + (params[:action] == 'edit' ? "<i class='fas fa-times padded-i remove-guest' data-guest-id="+id+"></i>" : "")
        end
      }.unshift(" hosting "+(params[:action] == 'edit' ? "&nbsp;&nbsp;&nbsp;&nbsp;" : "").html_safe).join.html_safe
    end
  end

  def episode_attribute(key, episode)
    if key == "color"
      raw(episode.attributes[key] +"&nbsp;&nbsp;<span style='display:inline-block;width:12px;height:12px;background-color:"+episode.attributes[key]+";'></span>")
    elsif key == "created_at" 
      episode.attributes[key]
    else
      episode.attributes[key]
    end
  end
end
