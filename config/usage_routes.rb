module UsageRoutes

  def mapPluginRoute(map, hostname_regex)
  map.connect '/browser/usages', :controller => "browser", :action => "usages"
  map.connect '/browser/usages/:server', :controller => "browser", :action => "usages",
    :requirements => {:server => hostname_regex}
  map.connect '/browser/usages/:server*path', :controller => "browser", :action => "usages",
    :requirements => {:server => hostname_regex}
  map.connect '/browser/usages.:format/:server*path', :controller => "browser", :action => "usages",
    :requirements => {:server => hostname_regex}
  end
end

