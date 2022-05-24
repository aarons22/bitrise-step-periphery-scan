#!/bin/bash

if [ -z "${path_to_project}" ] ; then
  echo " [!] Missing required input: path_to_project"

  exit 1
fi

cd "${path_to_project}"

# TODO: Bitrise expects xml to be formatted to JUnit XML, which is 
# not the same as the periphery `checkstyle`. A future iteration of this 
# should either convert to JUnit XML or supported plist format. More info:
# https://devcenter.bitrise.io/en/testing/test-reports.html#test-reports-overview
# For now, use `xcode` and manually parse the results
FLAGS="--quiet --format xcode"

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

# If the output file is empty, then there are no failures
if [ -n "$output" ]; then
    echo "[!] Periphery scan failed:"
    echo $output
    exit 1
fi

echo "Done"