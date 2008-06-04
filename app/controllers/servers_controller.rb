# Copyright (C) 2007 Rising Sun Pictures and Matthew Landauer
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

class ServersController < ApplicationController

  @timer_idle = true

  # GET /servers
  # GET /servers.xml
  def index
    Earth::File::with_filter do
      @servers = Earth::Server.find(:all)

      respond_to do |format|
        format.html # index.rhtml
        format.xml  { render :xml => @servers.to_xml }
      end
    end
  end

  # GET /servers/1
  # GET /servers/1.xml
  def show
    Earth::File::with_filter do
      @server = Earth::Server.find_by_name(params[:server])
      
      @users_space_usages = Earth::File.find(:all,
                                              :select => "sum(files.bytes) as space_usage, files.uid",
                                              :joins => "join directories on files.directory_id = directories.id",
                                              :group => "files.uid, directories.server_id",
                                              :conditions => [ "server_id = ? ", @server.id ])

      respond_to do |format|
        format.html # show.rhtml
        format.xml  { render :xml => @server.to_xml }
      end
    end
  end

  # GET /servers/1;edit
  def edit
    Earth::File::with_filter do
      @server = Earth::Server.find_by_name(params[:server])
    end
  end

  # PUT /servers/1
  # PUT /servers/1.xml
  def update
    @server = Earth::Server.find(params[:id])

    respond_to do |format|
      if @server.update_attributes(params[:server])
        flash[:notice] = 'Server was successfully updated.'
        format.html { redirect_to :action => "show", :params => { :server => @server.name } }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @server.errors.to_xml }
      end
    end
  end


  # GET /servers/1;configure
  def configure
    Earth::File::with_filter do
      @server = Earth::Server.find_by_name(params[:server])
    end
  end

  # PUT /servers/1
  # PUT /servers/1.xml
  def stopd_orig
    @server = Earth::Server.find(params[:id])
    @server.unfork_daemon
    respond_to do |format|
      if @server.update_attributes(params[:server])
        flash[:notice] = 'Server was successfully stopped.'
        format.html { redirect_to :action => "show", :params => { :server => @server.name } }
        format.xml  { head :ok }
      else
        format.html { render :action => "configure" }
        format.xml  { render :xml => @server.errors.to_xml }
      end
    end
  end

  # PUT /servers/1
  # PUT /servers/1.xml
  def startd_orig
    @server = Earth::Server.find(params[:id])
    @server.get_daemon_pid
    respond_to do |format|
      if @server.update_attributes(params[:server])
        flash[:notice] = 'Server was successfully started.'
        format.html { redirect_to :action => "show", :params => { :server => @server.name } }
        format.xml  { head :ok }
      else
        format.html { render :action => "configure" }
        format.xml  { render :xml => @server.errors.to_xml }
      end
    end
  end

  def startdaemon
    @server = Earth::Server.find(params[:id])
    @server.get_daemon_pid
    # initialize counter
    session[:counter] = 0
    # initialize stop loop variable
    @timer_idle = false
    session[:stop_timer] = false
    render :update do |page|
      # update the status
      page.replace_html 'daemon_status_message', 'Starting....'
      # start timer
      # page << "initialize_polling(1000);"
      # disable the start button
      page << "document.getElementById('start_daemon_button').disabled = true;"
      # highlight the updated div - so client notices
      page.visual_effect :highlight, 'daemon_status_message'
    end
  end

  # PUT /servers/1
  # PUT /servers/1.xml
  def stopdaemon
    @server = Earth::Server.find(params[:id])
    @server.unfork_daemon
    # change our conditional stop loop variable
    @timer_idle = true
    session[:stop_timer] = true
    render :update do |page|
      # update the status
      page.replace_html 'daemon_status_message', 'Stopping....'
      # disable the stop button
      page << "document.getElementById('stop_daemon_button').disabled = true;"
      # highlight the updated div - so client notices
      page.visual_effect :highlight, 'daemon_status_message'
    end
  end

  def update_daemon_status
    # count
    session[:counter] += 1
    render :update do |page|
      if session[:stop_timer] == false
      # if @timer_idle == false
        # update the status
        page.replace_html 'daemon_status_message', "Daemon up for: #{session[:counter]} seconds"
        # restart the timer
        page << "initialize_polling(1000);"
      else
        page.replace_html 'daemon_status_message', "Stopping.... reached: #{session[:counter]} seconds"
        # highlight the updated div - so client notices
        page.visual_effect :highlight, 'daemon_status_message'
      end
    end
  end

end
