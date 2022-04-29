#!/bin/bash

if [ -z "${path_to_project}" ] ; then
  echo " [!] Missing required input: path_to_project"

  exit 1
fi

cd "${path_to_project}"

FLAGS="--quiet --format checkstyle"

if [ "${skip_build}" = "true" ]; then
    FLAGS="--skip-build $FLAGS"
fi

if [ "${clean_build}" = "true" ]; then
    FLAGS="--clean-build $FLAGS"
fi

CONFIG_FILE=./.periphery.yml
if [ -f "$CONFIG_FILE" ] ; then
  echo "Automatically detected .periphery.yml"
  else 
  echo "Unable to automatically detect .periphery.yml"

  if [ -s "${xcode_workspace}" ] ; then
    FLAGS="--workspace ${xcode_workspace} $FLAGS"
  elif [ -s "${xcode_project}" ] ; then
    FLAGS="--project ${xcode_project} $FLAGS"
  else
    echo " [!] You must supply either the xcode_workspace or xcode_project option"
    exit 1
  fi

  if [ ! -s "${schemes}" ] ; then
    echo " [!] You must supply schemes option"
    exit 1
  fi

  FLAGS="--schemes ${schemes} $FLAGS"

  if [ ! -s "${targets}" ] ; then
    echo " [!] You must supply targets option"
    exit 1
  fi

  FLAGS="--targets ${targets} $FLAGS"
fi

echo "Starting scan with options: ${FLAGS}"
output="$(periphery scan ${FLAGS})"
echo "Scan finished, generating report"

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