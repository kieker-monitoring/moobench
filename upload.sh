#!/bin/bash

#
# Kieker moobench upload script
#
# Usage: upload.sh

# configure base dir
BASE_DIR=$(cd "$(dirname "$0")"; pwd)

KEYSTORE="$1"
UPDATE_SITE_URL="$2"

#
# source functionality
#

if [ ! -d "${BASE_DIR}" ] ; then
        echo "Base directory ${BASE_DIR} does not exist."
        exit 1
fi

# load configuration and common functions
if [ -f "${BASE_DIR}/config.rc" ] ; then
        source "${BASE_DIR}/config.rc"
else
        echo "Missing configuration: ${BASE_DIR}/config.rc"
        exit 1
fi

if [ -f "${BASE_DIR}/common-functions.sh" ] ; then
        source "${BASE_DIR}/common-functions.sh"
else
        echo "Missing library: ${BASE_DIR}/common-functions.sh"
        exit 1
fi

checkExecutable compile-results "${COMPILE_RESULTS_BIN}"
checkFile keystore "${KEYSTORE}"
checkDirectory results "${BASE_DIR}/results" recreate

if [ "${UPDATE_SITE_URL}" == "" ] ; then
	error "Missing UPDATE_SITE_URL"
	info "Usage: $0 KEYSTORE UPDATE_SITE_URL"
	exit 1
fi

# Retrieve logs
cd results

info "Get Kieker-java log"
sftp -oNoHostAuthenticationForLocalhost=yes -oStrictHostKeyChecking=no -oUser=repo -F /dev/null -i ${KEYSTORE} ${UPDATE_SITE_URL}/Kieker-java-log.yaml

info "Get Kieker-python log"
sftp -oNoHostAuthenticationForLocalhost=yes -oStrictHostKeyChecking=no -oUser=repo -F /dev/null -i ${KEYSTORE} ${UPDATE_SITE_URL}/Kieker-python-log.yaml

info "Get OpenTelemetry log"
sftp -oNoHostAuthenticationForLocalhost=yes -oStrictHostKeyChecking=no -oUser=repo -F /dev/null -i ${KEYSTORE} ${UPDATE_SITE_URL}/OpenTelemetry-java-log.yaml

info "Get inspectIT log"
sftp -oNoHostAuthenticationForLocalhost=yes -oStrictHostKeyChecking=no -oUser=repo -F /dev/null -i ${KEYSTORE} ${UPDATE_SITE_URL}/inspectIT-java-log.yaml
cd ..

# Compute logs and charts
info "Compute new logs and charts"
"${COMPILE_RESULTS_BIN}" -i *-results.yaml -l results -c results -t results -w 100

# Stash results back onto the update site
info "Push logs and results"

cd results
echo "put *.yaml" | sftp -oNoHostAuthenticationForLocalhost=yes -oStrictHostKeyChecking=no -oUser=repo  -F /dev/null -i ${KEYSTORE} ${UPDATE_SITE_URL}
echo "put *.html" | sftp -oNoHostAuthenticationForLocalhost=yes -oStrictHostKeyChecking=no -oUser=repo  -F /dev/null -i ${KEYSTORE} ${UPDATE_SITE_URL}
echo "put *.json" | sftp -oNoHostAuthenticationForLocalhost=yes -oStrictHostKeyChecking=no -oUser=repo  -F /dev/null -i ${KEYSTORE} ${UPDATE_SITE_URL}
cd ..

info "Done"
# end
