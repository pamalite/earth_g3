!# /bin/bash

echo '======  Deleting user-defined settings ======'
echo ''
echo 'deleting log folder'
rm -rf log
echo 'log folder deleted'
echo ''

echo 'Deleting config/keys folder...'
rm -rf config/keys
echo 'config/keys folder deleted.'
echo ''

echo 'Deleting config/certificates folder...'
rm -rf config/certificates
echo 'config/certificates folder deleted.'
echo ''

echo '====== User-defined settings deleted. ======'
