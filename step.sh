#!/bin/bash
set -ex

if [ -z "${path_to_project}" ] ; then
  echo " [!] Missing required input: path_to_project"

  exit 1
fi

cd "${path_to_project}"

# TODO: check for periphery file. If not, check parameters to build the scan

output="$(periphery scan --quiet --format checkstyle)"
envman add --key "PERIPHERY_REPORT" --value "${output}"

report_path="${BITRISE_DEPLOY_DIR}/${report_file}.xml"
echo "${output}" > $report_path
envman add --key "PERIPHERY_REPORT_PATH" --value "${report_path}"

# Creating the sub-directory for the test run within the BITRISE_TEST_RESULT_DIR:
test_run_dir="$BITRISE_TEST_RESULT_DIR/Periphery"
mkdir "$test_run_dir"

# Exporting the JUnit XML test report:
cp $report_path "$test_run_dir/UnitTest.xml"

# Creating the test-info.json file with the name of the test run defined:
echo '{"test-name":"Swiftlint"}' >> "$test_run_dir/test-info.json"
echo "Done"