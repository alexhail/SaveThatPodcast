module ApplicationHelper

  def render_partial(partial, opts={})
    skip_controllers = {
      navigation: ["home"],
      flash: ["sessions"],
      admin_link: ["sessions"],
      top_left_nav: [""]
    }

    skip_actions = {
      navigation: [""],
      flash: [""],
      admin_link: [""],
      top_left_nav: [""]
    }

    no_controller = skip_controllers[partial]
    no_action = skip_actions[partial]

    unless no_controller.include?(controller_name) || no_action.include?(action_name)
      unless opts.empty?
        if opts[:type].present?
          render partial: 'partials/' + partial.to_s, locals: { type: opts[:type].to_s }
        end
      else
        render 'partials/' + partial.to_s
      end
    end
  end

  def flash_icon(key)
    case key
    when "alert"
      "far fa-times-circle"
    when "notice"
      "fas fa-exclamation-circle"
    when "admin"
      "fas fa-crown"
    else
      "fas fa-exclamation-circle"
    end
  end

  def current_route_contains?(url)
    return true if request.path_info.include?(url)
  end

end
