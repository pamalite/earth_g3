!# /bin/bash

clear

echo 'Creating log folder'
mkdir log
echo 'log folder created'

echo 'Creating log/development.log file'
touch log/development.log
echo 'log/development.log file created'

echo 'Creating log/test.log file'
touch log/test.log
echo 'log/test.log file created'

echo 'Setting log files privileges'
chmod 0666 log/*.log
echo 'log files created'
echo ''
