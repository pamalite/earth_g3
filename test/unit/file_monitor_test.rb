class FileMonitorTest < Test::Unit::TestCase
  def setup
    # Put some test files in the directory test_data
    @relative_dir = 'test_data'
    @dir = File.expand_path(@relative_dir)
    @file1 = File.join(@dir, 'file1')
    @dir1 = File.join(@dir, 'dir1')
    @file2 = File.join(@dir1, 'file1')

    FileUtils.rm_rf @dir
    FileUtils.mkdir_p @dir1
    FileUtils.touch @file1
    FileUtils.touch @file2
    
    # Changes the access and modification time to be one minute in the past
    past = Time.now - 60
    File.utime(past, past, @dir)
    File.utime(past, past, @dir1)
    File.utime(past, past, @file1)
    File.utime(past, past, @file2)
    
    # Clears the contents of the database
    Earth::File.delete_all
    Earth::Directory.delete_all
    Earth::Server.delete_all

    server = Earth::Server.this_server
    @directory = server.directories.create(:name => @dir)
  end
  
  def teardown
    # Tidy up
    File.chmod(0777, @dir1) if File.exist?(@dir1)
    FileUtils.rm_rf 'test_data'
  end
  
  # Compare directory object with a directory on the filesystem
  def assert_directory(path, directory)
    assert_equal(path, directory.path)
    assert_equal(File.lstat(path), directory.stat)  
  end
  
  # Compare file object with a file on the filesystem
  def assert_file(path, file)
    assert_equal(File.dirname(path), file.directory.path)
    assert_equal(File.basename(path), file.name)
    assert_equal(File.lstat(path), file.stat)
  end

  def assert_directories(paths, directories)
    assert_equal(paths.size, directories.size)
    paths.each_index{|i| assert_directory(paths[i], directories[i])}
  end
  
  def assert_files(paths, files)
    assert_equal(paths.size, files.size)
    paths.each_index{|i| assert_file(paths[i], files[i])}
  end
  
  def test_ignore_dot_files
    FileUtils.touch 'test_data/.an_invisible_file'
    FileUtils.touch 'test_data/.another'
    FileMonitor.update(@directory)
    assert_nil(Earth::File.find_by_name('.an_invisible_file'))
    assert_nil(Earth::File.find_by_name('.another'))
  end
  
  def test_added
    FileMonitor.update(@directory)
    assert_directories([@dir, @dir1], Earth::Directory.find(:all))
    assert_files([@file2, @file1], Earth::File.find(:all))
  end

  def test_removed
    FileMonitor.update(@directory)
    FileUtils.rm_rf 'test_data/dir1'
    FileUtils.rm 'test_data/file1'
    FileMonitor.update(@directory)
    
    assert_directories([@dir], Earth::Directory.find(:all))
    assert_files([], Earth::File.find(:all))
  end

  def test_removed2
    dir2 = File.join(@dir1, 'dir2')
    
    FileUtils.mkdir dir2
    FileUtils.touch File.join(dir2, 'file')
    FileMonitor.update(@directory)
    FileUtils.rm_rf @dir1
    FileMonitor.update(@directory)
    
    assert_directories([@dir], Earth::Directory.find(:all))
    assert_files([@file1], Earth::File.find(:all))
  end
  
  def test_changed
    FileMonitor.update(@directory)
    FileUtils.touch @file2
    # For the previous change to be noticed we need to create a new file as well
    # This is only strictly true for the PosixFileMonitor
    file3 = File.join(@dir1, 'file2')
    FileUtils.touch file3
    FileMonitor.update(@directory)
    
    assert_directories([@dir, @dir1], Earth::Directory.find(:all))
    assert_files([@file2, @file1, file3], Earth::File.find(:all))
  end
  
  def test_added_in_subdirectory
    FileMonitor.update(@directory)
    file3 = File.join(@dir1, 'file2')
    FileUtils.touch file3
    FileMonitor.update(@directory)
    
    assert_directories([@dir, @dir1], Earth::Directory.find(:all))
    assert_files([@file2, @file1, file3], Earth::File.find(:all))
  end

  # If the daemon doesn't have permission to list the directory
  # it should ignore it
  def test_permissions_directory
    # Remove all permission from directory
    mode = File.stat(@dir1).mode
    File.chmod(0000, @dir1)
    FileMonitor.update(@directory)
    
    assert_directories([@dir, @dir1], Earth::Directory.find(:all))
    assert_files([@file1], Earth::File.find(:all))

    # Add permissions back
    File.chmod(mode, @dir1)
  end
  
  def test_directory_executable_permissions
    # Make a directory readable but not executable
    mode = File.stat(@dir1).mode
    File.chmod(0444, @dir1)
    FileMonitor.update(@directory)
    
    assert_directories([@dir, @dir1], Earth::Directory.find(:all))
    assert_files([@file1], Earth::File.find(:all))

    # Add permissions back
    File.chmod(mode, @dir1)
  end
  
  def test_removed_watched_directory
    FileMonitor.update(@directory)
    FileUtils.rm_rf @dir
    FileMonitor.update(@directory)
    
    directories = Earth::Directory.find(:all)
    assert_equal(1, directories.size)
    assert_equal(@dir, directories[0].path)
    # Not checking the stat of the top directory as it has been deleted
    
    files = Earth::File.find(:all)
    assert_equal(0, files.size)
  end
end
