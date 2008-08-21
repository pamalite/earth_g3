module UsagesHelper

  $the_sections << :usages

  $tab_info << {:title => "user usages", :controller => "browser", :action => "usages"}

  def usages
    server = Earth::Server.find_by_name(params[:server])
    if server == nil then
      @users_space_usages = Earth::File.find(:all,
                                              :select => "sum(files.bytes) as space_usage, files.uid, directories.server_id",
                                              :joins => "join directories on files.directory_id = directories.id",
                                              :group => "files.uid, directories.server_id")
    else
      @users_space_usages = Earth::File.find(:all,
                                              :select => "sum(files.bytes) as space_usage, files.uid, directories.server_id",
                                              :joins => "join directories on files.directory_id = directories.id",
                                              :group => "files.uid, directories.server_id",
                                              :conditions => [ "server_id = ? ", server ])
    end
  end
end
