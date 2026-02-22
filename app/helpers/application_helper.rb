module ApplicationHelper
  # Sidebar navigation link helper
  # Renders an icon-only link (48px sidebar) with a tooltip for the label.
  # `active:` highlights the current page, `disabled:` greys it out for future pages.
  def sidebar_link(label, path, key, active: false, disabled: false, &block)
    icon_html = capture(&block)

    if disabled
      content_tag(:div,
        content_tag(:div, icon_html, class: "flex items-center justify-center w-9 h-9"),
        class: "flex items-center rounded-md text-content-muted/40 cursor-default",
        title: "#{label} (coming soon)"
      )
    else
      link_to(path,
        class: "group flex items-center rounded-md transition-colors #{active ? 'bg-bg-elevated text-accent' : 'text-content-secondary hover:bg-bg-elevated hover:text-content'}",
        title: label,
        aria: { label: label, current: (active ? "page" : nil) },
        data: { turbo_frame: "_top" }
      ) do
        content_tag(:div, icon_html, class: "flex items-center justify-center w-9 h-9")
      end
    end
  end

  def platform_emoji(platform)
    case platform.to_s
    when "x" then "𝕏"
    when "instagram" then "📸"
    when "linkedin" then "💼"
    when "threads" then "🧵"
    when "youtube" then "▶️"
    when "email_newsletter" then "📧"
    when "general" then "📝"
    else "📄"
    end
  end

  def activity_icon_bg(activity)
    case activity.action
    when "created"
      "bg-status-info/20"
    when "moved"
      "bg-purple-900/30"
    when "updated"
      "bg-status-warning/20"
    else
      "bg-bg-elevated"
    end
  end

  def activity_icon(activity)
    case activity.action
    when "created"
      '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-3 h-3 text-status-info"><path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" /></svg>'.html_safe
    when "moved"
      '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-3 h-3 text-purple-400"><path stroke-linecap="round" stroke-linejoin="round" d="M7.5 21 3 16.5m0 0L7.5 12M3 16.5h13.5m0-13.5L21 7.5m0 0L16.5 12M21 7.5H7.5" /></svg>'.html_safe
    when "updated"
      '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-3 h-3 text-status-warning"><path stroke-linecap="round" stroke-linejoin="round" d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L10.582 16.07a4.5 4.5 0 0 1-1.897 1.13L6 18l.8-2.685a4.5 4.5 0 0 1 1.13-1.897l8.932-8.931Z" /></svg>'.html_safe
    else
      '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-3 h-3 text-content-secondary"><path stroke-linecap="round" stroke-linejoin="round" d="M12 6v6h4.5m4.5 0a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" /></svg>'.html_safe
    end
  end
end
