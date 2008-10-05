!# /bin/bash

echo '======  Preparing ser-defined settings ======'
echo ''
echo 'Creating log folder'
mkdir log
echo 'log folder created'
echo ''

echo 'Creating log/development.log file'
touch log/development.log
echo 'log/development.log file created'
echo ''

echo 'Creating log/test.log file'
touch log/test.log
echo 'log/test.log file created'
echo ''

echo 'Setting log files privileges'
chmod 0666 log/*.log
echo 'log files created'
echo ''

echo 'Creating config/keys folder...'
mkdir config/keys
echo 'config/keys folder created.'
echo ''

echo 'Creating config/certificates folder...'
mkdir config/certificates
echo 'config/certificates folder created'
echo ''

echo '====== User-defined settings prepared. ======'
