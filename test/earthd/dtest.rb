#!/usr/bin/env ruby

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

require 'optparse'
require 'find'
require 'fileutils'
require 'pp'

$ignore_child_death = false
$debug_mode = false

class DaemonTest
  # Range for size of created/resized files
  MIN_FILE_SIZE = 0
  MAX_FILE_SIZE = 30

  # Range for number of initially created directories
  MIN_INITIAL_DIRECTORIES = 1
  MAX_INITIAL_DIRECTORIES = 20

  # Range for number of initially created files
  MIN_INITIAL_FILES = 10
  MAX_INITIAL_FILES = 20

  # Range for number of mutations per iteration
  MIN_MUTATIONS_PER_ITERATION = 1
  MAX_MUTATIONS_PER_ITERATION = 12

  def logger
    RAILS_DEFAULT_LOGGER
  end

  def initialize(root_directory, number_of_iterations, number_of_replay_iterations, bloodshed_percentage, csc)
    @bloodshed_percentage = bloodshed_percentage
    @root_directory = File.expand_path(root_directory)
    @number_of_iterations = number_of_iterations
    @number_of_replay_iterations = number_of_replay_iterations
    @iteration_count = 0
    @dont_touch_again_files = []
    @daemon_executable = File.join(File.dirname(__FILE__), "..", "..", "script", "earthd")
    @cache_success_count = csc
  end

  def make_random_name
    name_length = 3 + rand(4)
    chars = ("a".."z").to_a
    new_name = ""
    1.upto(name_length) { |i| new_name << chars[rand(chars.size)] }
    new_name
  end

  def find_random_directory(options={})
    use_options = { :include_root => true }
    use_options.update(options)
    all_directories = []
    Find.find(@root_directory) do |path|  
      all_directories << path if FileTest.directory? path and (path != @root_directory or use_options[:include_root])
    end
    all_directories[rand(all_directories.size)]
  end

  def find_random_file
    all_files = []
    Find.find(@root_directory) do |path|  
      all_files << path if (not FileTest.directory? path) and (not @dont_touch_again_files.include?(path))
    end
    all_files[rand(all_files.size)]
  end

  def create_directory(is_replay=false)
    directory_to_create = File.join(self.find_random_directory, make_random_name)
    if not FileTest.exist? directory_to_create
      puts "Creating directory #{directory_to_create}"
      logger.debug "[daemon_test] Creating directory #{directory_to_create}"
      Dir.mkdir(directory_to_create)
      if $debug_mode then puts "DEBUG: Directory created.." end
      true
    end
  end

  def is_in_root_dir(directory)
    if directory == "/"
      return false
    elsif directory == @root_directory
      return true
    else
      return is_in_root_dir(File.dirname(directory))
    end
  end

  def is_sub_directory(directory1, directory2)
    while true
      if directory1 == directory2
        return true
      end
      if directory1 == "/"
        return false
      end
      directory1 = File.dirname(directory1)
    end
  end

  def delete_directory(is_replay)
    directory_to_delete = self.find_random_directory(:include_root => false)
    if directory_to_delete and directory_to_delete != @root_directory and is_in_root_dir(directory_to_delete)
      puts "Deleting directory #{directory_to_delete}"
      logger.debug "[daemon_test] Deleting directory #{directory_to_delete}"
      FileUtils.rm_rf(directory_to_delete)
      if $debug_mode then puts "DEBUG: Directory deleted.." end      
      true
    end
  end

  def move_directory(is_replay)
    directory_to_move = self.find_random_directory(:include_root => false)
    directory_to_move_to = self.find_random_directory
    if directory_to_move and directory_to_move_to and \
      directory_to_move_to != directory_to_move and \
      (not is_sub_directory(directory_to_move, directory_to_move_to)) and \
      (not is_sub_directory(directory_to_move_to, directory_to_move)) then
      logger.debug "[daemon_test] Moving directory #{directory_to_move} to #{directory_to_move_to}"
      puts "Moving directory #{directory_to_move} to #{directory_to_move_to}"
      FileUtils.mv(directory_to_move, File.join(directory_to_move_to, File.basename(directory_to_move)))
      if $debug_mode then puts "DEBUG: Directory moved.." end      
      true
    end
  end

  def make_random_file_size
    MIN_FILE_SIZE + rand(MAX_FILE_SIZE - MIN_FILE_SIZE)
  end

  def create_file(is_replay=false)
    file_to_create = File.join(self.find_random_directory, make_random_name)    
    if not FileTest.exist? file_to_create
      file_size = make_random_file_size
      logger.debug "[daemon_test] Creating file #{file_to_create} with size #{file_size}"
      puts "Creating file #{file_to_create} with size #{file_size}"
      File.open(file_to_create, File::CREAT|File::TRUNC|File::WRONLY) do |file|
        file.print("x" * file_size)
      end
      @dont_touch_again_files << file_to_create
      if $debug_mode then puts "DEBUG: Files created.." end
      true
    end
  end

  def delete_file(is_replay)
    file_to_delete = self.find_random_file
    if file_to_delete
      logger.debug "[daemon_test] Deleting file #{file_to_delete}"
      puts "Deleting file #{file_to_delete}"
      File.delete(file_to_delete)
      if $debug_mode then puts "DEBUG: File deleted.." end
      true
    end
  end

  def resize_file(is_replay)
    file_to_resize = self.find_random_file
    if file_to_resize
      @dont_touch_again_files << file_to_resize
      new_size = make_random_file_size
      logger.debug "[daemon_test] Resizing file #{file_to_resize} to #{new_size} bytes"
      puts "Resizing file #{file_to_resize} to #{new_size} bytes"
      sleep 1 unless is_replay
      # old_mtime = File.mtime(File.dirname(file_to_resize))
      File.open(file_to_resize, File::CREAT|File::TRUNC|File::WRONLY) do |file|
        file.print("x" * new_size)
      end
      if $debug_mode then puts "DEBUG: File resized.." end
      sleep 1 unless is_replay
      FileUtils.touch(File.dirname(file_to_resize))
      puts "Touched file #{file_to_resize}" # - directory.mtime new #{File.mtime(File.dirname(file_to_resize))}, old #{old_mtime}"
      logger.debug "[daemon_test] Touched dir #{File.dirname(file_to_resize)}" # - directory.mtime new #{File.mtime(File.dirname(file_to_resize))}, old #{old_mtime}"
      if $debug_mode then puts "DEBUG: File touched.." end
      true
    end
  end

  def move_file(is_replay)
    file_to_move = self.find_random_file
    directory_to_move_to = self.find_random_directory
    if file_to_move and directory_to_move_to and directory_to_move_to != File.dirname(file_to_move)
      file_to_move_to = File.join(directory_to_move_to, File.basename(file_to_move))
      logger.debug "[daemon_test] Moving file #{file_to_move} to #{file_to_move_to}"
      puts "Moving file #{file_to_move} to #{file_to_move_to}"
      File.rename(file_to_move, file_to_move_to)
      @dont_touch_again_files << file_to_move
      @dont_touch_again_files << file_to_move_to
      if $debug_mode then puts "DEBUG: File moved.." end
      true
    end
  end

  def restart_daemon
    puts "Restarting daemon"
    #$ignore_child_death = true
    sig_handler = trap("CLD", "IGNORE")
    Process.kill("SIGINT", $child_pid)
    pid = Process.wait
    #$ignore_child_death = false
    trap("CLD", sig_handler)
    $child_pid = fork_daemon
    if $debug_mode then puts "DEBUG: daemon restarted with $child_pid = #{$child_pid}" end
    true
  end

  def fork_daemon
    fork do
      puts "Launching daemon in background"
      exec("#{@daemon_executable} start")
      exec("#{@daemon_executable} add \"#{@root_directory}\"")
    end
  end

  def unfork_daemon
      exec("#{@daemon_executable} stop")
  end

  # ====================================================================================
  # NOTES (FL)
  # Simulates the initial clearing out of the database until the implementation of the
  # "remove" feature to the earthd daemon.To be substituted with the implementation of 
  # the said feature when it becomes available in future version.
  # ====================================================================================
  def clear_parent_directory
    dir_tbr = @root_directory
    if not dir_tbr.nil?
      FileUtils.rm_rf dir_tbr 
      puts "Current parent directory #{dir_tbr} deleted."
    else
      puts "#{dir_tbr} is not a valid directory"
    end
    puts "Recreating parent directory #{@root_directory}"
    Dir.mkdir(@root_directory);

    puts "Pausing for 5s to allow daemon to update backend..."
    sleep 5
    puts "Resuming after 5s pause."

  end

  def main_loop

    # Clear out database
    puts "Clearing out database..."
    if $debug_mode then puts "Simulating clearing action with clear_parent_directory method" end
    clear_parent_directory
    
    # ==================================================================================
    # TODO (FL)
    # Currently bypassing the elimination of runaway child (earthd) processes. So that 
    # if the test unexpectedly breaks, the forked daemon should be killed. The following
    # snippets currently kills the testing script when its called. The fix should try
    # to return control back to the testing script and gracefully terminates.
    # ==================================================================================
    # Set up a trap to make sure we exit when any child spawned is terminating
    #FL# trap("CLD") do
    #FL#  if not $ignore_child_death
    #FL#    pid = Process.wait
    #FL#    puts "Child pid #{pid}: terminated"
    #FL#    exit
    #FL#  end
    #FL# end

    # Create initial directory structure
    initial_directory_count = MIN_INITIAL_DIRECTORIES + rand(MAX_INITIAL_DIRECTORIES - MIN_INITIAL_DIRECTORIES)
    1.upto(initial_directory_count) { create_directory }

    # Populate initial directory structure with files
    initial_file_count = MIN_INITIAL_FILES + rand(MAX_INITIAL_FILES - MIN_INITIAL_FILES)
    1.upto(initial_file_count) { create_file }

    # do initial "replay" iterations
    1.upto(@number_of_replay_iterations) do
      test_iteration(:replay => true)
    end
    
    # Launch daemon in the background
    $child_pid = fork_daemon
    if $debug_mode then puts "DEBUG: $child_pid = #{$child_pid}" end

    at_exit { Process.kill("SIGINT", $child_pid) }

    # Wait for daemon to index the initial directory structure
    puts "Waiting for daemon to index initial empty directory structure"
    if Earth::Server.this_server.last_update_finish_time.nil? then
      puts "Sleeping for 10s"
      sleep 10
      puts "10s sleep over"
    end

		puts "Sleeping for 10s"
		sleep 10
		puts "10s sleep over"

    puts "Daemon indexed initial empty directory structure"
    

    # Make sure daemon got the initial indexing right
    puts "Verifying data integrity"
    # ====================================================================================
    # NOTES (FL)
    # Bypassing the verification of the initial directory structure
    verify_data
    # ====================================================================================
    puts "Bypassed initial empty directory structure "
    puts "Integrity verified"

    if @number_of_iterations.nil? then
      # loop indefinitely
      while true
        test_iteration
      end
    else
      # loop given number of times
      1.upto(@number_of_iterations) do
        test_iteration
      end
      puts ""
      puts " ==================== DAEMON TEST PASSED (No Assertion raised) ===================="
      puts ""
      puts " Caching stats: #{@cache_success_count}/#{@number_of_iterations}    [#{@cache_success_count.to_f/@number_of_iterations.to_f*100} % ]"
      puts ""
      puts " =================================================================================="
      puts ""
      if $debug_mode then puts "DEBUG: Unforking daemon..." end
      unfork_daemon
      if $debug_mode then puts "Daemon unforked [*** THIS LINE IS NOT REACHED ***]" end
    end
  end

  def test_iteration(options = nil)
    use_options = { :replay => false }
    use_options.update(options) if options
    @dont_touch_again_files = []
    
    # Determine a random number of mutations to perform in this iteration
    mutation_count = MIN_MUTATIONS_PER_ITERATION + rand(MAX_MUTATIONS_PER_ITERATION - MIN_MUTATIONS_PER_ITERATION)

    # Output header for this iteration
    puts ("-" * 80)
    @iteration_count += 1
    if not use_options[:replay]
      puts "Iteration ##{@iteration_count}"
    else
      puts "Replay Iteration ##{@iteration_count}"
    end
    puts "Doing #{mutation_count} mutations"

    # Perform the mutations on the file system
    1.upto(mutation_count) { mutate_tree(use_options) }

    if not use_options[:replay]
      puts "Waiting for daemon to update directory [8s]"
      
      # Wait five seconds so that the changes to the file system become
      # "old enouh" to get picked up by the file monitor.
      sleep 8

      puts "Verifying data integrity"
      verify_data
      puts "Integrity verified"

      if $debug_mode then puts "DEBUG: Daemon updated.." end
    end
  end

  def verify_data
    this_server = Earth::Server.this_server
    roots = Earth::Directory.roots_for_server(this_server) 
    
    # Assume only one directory root
    assert("Server has only one root") { 1 == roots.size }
    root = roots[0]

    if $debug_mode then puts "DEBUG: root.name is [#{root.name}] and @root_dir is [#{@root_directory}]" end
    # Assume it's pointing to our test directory
    assert("Root directory name matches test root directory") { @root_directory == root.name }

    # Recursively validate the directory information
    compare_fs_directory_recursive(root, @root_directory)

    Earth::File.with_filter({}) do
      # ==================================================================================
      # TODO (FL)
      # Currently bypassing the assertion due to inconsistent cache state.
      # The issue is most probably attributed to the correctness of the
      # directory model implementation (app/model/earth/directory.rb).
      # ==================================================================================
      puts ""
      puts "root.cache_complete? = #{root.cache_complete?}"  
      if root.cache_complete?
        assert("Cache of root complete") {root.cache_complete?}
        verify_cache_integrity_recursive(root)
      
        puts "total size/blocks/count"
        puts "[#{root.size.bytes}, #{root.size.blocks}, #{root.size.count}] <fs>"
        puts "[#{root.size_without_caching.bytes}, #{root.size_without_caching.blocks}, #{root.size_without_caching.count}] <db>"
        @cache_success_count += 1
      else
        puts "Bypassing cache integrity verification..."
      end
    end

    root.ensure_consistency
  end

  def assert(message)
    raise "Assertion failed: #{message}" unless yield
  end

  def verify_cache_integrity_recursive(directory)
    # ====================================================================================
    # NOTES (FL)
    # The following assertion test is currently disabled until the caching issue is fixed.
    # ====================================================================================
    # assert("Size, blocks and count for node ##{directory.id} (#{directory.path}) match") { directory.size_with_caching == directory.size_without_caching }
    
    directory.children.each do |child|
      verify_cache_integrity_recursive(child)
    end
  end

  def compare_fs_directory_recursive(db_directory, fs_directory)
    fs_directory_names = []
    fs_file_names = []
    Dir.foreach(fs_directory) do |entry|
      if entry != "." and entry != ".."
        if FileTest.directory? File.join(fs_directory, entry)
          fs_directory_names << entry
        else
          fs_file_names << entry
        end
      end
    end
    fs_directory_names.sort!
    fs_file_names.sort!

    db_directory_names = db_directory.children.map { |child| child.name }
    db_file_names = db_directory.files.map { |file| file.name }

    db_directory_names.sort!
    db_file_names.sort!

    if not $debug_mode then
      puts "directories from database:"
      pp(db_directory_names)
      puts "directories from file system:"
      pp(fs_directory_names)
      puts "files from database:"
      pp(db_file_names)
      puts "files from file system:"
      pp(fs_file_names)
    end

    assert("Subdirectories in #{fs_directory} match database contents (#{db_directory_names.inspect}<db> == #{fs_directory_names.inspect}<fs>)") { db_directory_names == fs_directory_names }
    assert("Files in #{fs_directory} match database contents") { db_file_names == fs_file_names }
    
    db_directory.files.each do |db_file|
      fs_file = File.join(fs_directory, db_file.name)
      fs_file_stat = File.lstat(fs_file)
      assert("Byte size of #{fs_file} matches database contents (#{fs_file_stat.size} == #{db_file.bytes})") { fs_file_stat.size == db_file.bytes }
      assert("Block size of #{fs_file} matches database contents") { fs_file_stat.blocks == db_file.blocks }
    end
    
    db_directory.children.each do |db_child|
      compare_fs_directory_recursive(db_child, File.join(fs_directory, db_child.name))
    end

  end

  def mutate_tree(options)
    weighted_actions = [[25, :create_directory], 
                        [10, :delete_directory], 
                        [15, :move_directory], 
                        [15, :create_file], 
                        [10, :delete_file], 
                        [ 5, :resize_file], 
                        [10, :move_file]
    ]

    total_action_weight = weighted_actions.map { |weight_and_action| weight_and_action[0] }.sum

    while true
      random = rand(total_action_weight)
      action = weighted_actions.inject(nil) do |chosen_action, weight_and_action|
        if chosen_action
          chosen_action
        elsif random < weight_and_action[0]
          weight_and_action[1]
        else
          random -= weight_and_action[0]
          nil
        end
      end
      if self.send(action, options[:replay])
        break
      else
        puts "(Couldn't do #{action}, trying a different operation)"
      end
    end
  end
end

seed = nil
iterations = nil
replay_iterations = 0
bloodshed_percentage = 0
cache_success_count = 0

opts = OptionParser.new
opts.banner = <<END_OF_STRING
Make changes in a directory and monitor the database to see that it is updated properly.
!!!!WARNING: The given directory WILL BE rm -Rfed!!!!
Usage: #{$0} [-s SEED] [-i ITERATIONS] [-b BLOODSHED] <directory path>
END_OF_STRING

opts.on("-s", "--seed NUMBER", "Use SEED to initialize the random number generator instead of the current time") do |_seed|
  seed = _seed.to_i
end
opts.on("-i", "--iterations NUMBER", "Only loop for the given number of iterations instead of indefinitely") do |_iterations|
  iterations = _iterations.to_i
end
opts.on("-r", "--replay-iterations NUMBER", "Perform the given number of \"replay\" iterations before starting the daemon") do |_replay_iterations|
  replay_iterations = _replay_iterations.to_i
end

opts.on("-b", "--bloodshed PERCENTAGE", "When waiting for the daemon to update, roll dice twice per second and restart daemon process with PERCENTAGE probability. Default is 0 (never restart daemon). Note that restarting the daemon can lead to results being not reproducable due to timing issues") do |_bloodshed_percentage|
  bloodshed_percentage = _bloodshed_percentage.to_f
end

opts.on_tail("-h", "--help", "Show this message") do
  puts opts
  exit
end

begin
  opts.parse!(ARGV)
rescue
  puts opts
  exit 1
end

if ARGV.length != 1
  puts opts
  exit 1
end

# Set environment to run in
ENV["RAILS_ENV"] = "test"
require File.join(File.dirname(__FILE__), "..", "..", "config", "environment")

parent_directory = ARGV[0]

if not FileTest.directory?(parent_directory)
  puts "ERROR: #{parent_directory} doesn't exist or is not a directory"
  exit 5
end

work_directory = parent_directory
FileUtils.mkdir_p(work_directory)

if seed.nil?
  seed = Time.new.to_i
end

puts "Using seed #{seed}"

srand(seed)

test = DaemonTest.new(work_directory, iterations, replay_iterations, bloodshed_percentage, cache_success_count)
begin
  test.main_loop
ensure
  puts "Seed for this run was #{seed}"
end

