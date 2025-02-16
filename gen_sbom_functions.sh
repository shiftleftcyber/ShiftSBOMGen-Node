#!/usr/bin/env bash

# shellcheck disable=SC2002
# SC2002 (style): the cat command is used inside of jq

set -e

# Statics
DEFAULT_OUTPUT_DIRECTORY="sbom_output"
SWITCHES=()

## purpose: generate a CycloneDX sBOM

check_output_directory() {
  if [ -n "${OUTPUT_DIRECTORY}" ]; then
    export OUTPUT_DIR="${OUTPUT_DIRECTORY}"
  else
    export OUTPUT_DIR="${DEFAULT_OUTPUT_DIRECTORY}"
  fi

  echo "writing output to ${OUTPUT_DIR}"
  if [ ! -d "${OUTPUT_DIR}" ]; then
    echo "creating ${OUTPUT_DIR}"
    mkdir "${OUTPUT_DIR}"
  else
    echo "${OUTPUT_DIR} already exists"
  fi
}

set_sbom_filename() {
  check_output_directory
  get_package_version

  if [ -n "${SBOM_FILENAME}" ]; then
    OUTPUT_FILENAME="${OUTPUT_DIR}/${SBOM_FILENAME}"
  elif [ -n "${BITBUCKET_REPO_SLUG}" ]; then
    OUTPUT_FILENAME="${OUTPUT_DIR}/${BITBUCKET_REPO_SLUG}-${PACKAGE_VERSION}.cdx"
  else
    OUTPUT_FILENAME="${OUTPUT_DIR}/sbom-${PACKAGE_VERSION}.cdx"
  fi

  # set the file extension
  if [ -n "${NPM_OUTPUT_FORMAT}" ]; then
    OUTPUT_FILENAME="${OUTPUT_FILENAME}.${NPM_OUTPUT_FORMAT}"
  else
    OUTPUT_FILENAME="${OUTPUT_FILENAME}.json"
  fi

  echo "sBOM will be written to ${OUTPUT_FILENAME}"
  SWITCHES+=("--output-file" "${OUTPUT_FILENAME}")
}

get_package_version() {
  get_version
  echo "package verison is is set to: ${PACKAGE_VERSION}"
  if [ "${PACKAGE_VERSION}" == "null" ]; then
    echo "WARNING: version field is not set in package.json"
    PACKAGE_VERSION=0.0.0
  fi
}

get_version() {
  PACKAGE_VERSION=$(cat package.json | jq --raw-output .version)
}

help() {
  echo "Generates a CycloneDX sBOM file for the given project"
}

generate_cyclonedx_sbom_for_npm_project() {
  CYCLONEDX_NPM_VERSION=$(cyclonedx-npm --version)
  verify_cyclonedx
  generate_switches
  cyclonedx-npm "${SWITCHES[@]}"
}

verify_cyclonedx() {
  echo "verifying @cyclonedx/cyclonedx-npm is installed"

  if [[ "${CYCLONEDX_NPM_VERSION}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "version ${CYCLONEDX_NPM_VERSION} of cyclonedx-npm is installed"
  else
    echo "ERROR: cannot validate version of cyclonedx-npm. Verify npm package is installed"
    exit 1
  fi
}

generate_switches() {
  if [ "${NPM_PACKAGE_LOCK_ONLY}" = true ]; then
    SWITCHES+=('--package-lock-only')
  fi

  # for legacy purposes IGNORE_NPM_ERRORS is not being appended with NPM_
  if [ "${IGNORE_NPM_ERRORS}" = true ]; then
    SWITCHES+=('--ignore-npm-errors')
  fi

  if [ "${NPM_FLATTEN_COMPONENTS}" = true ]; then
    SWITCHES+=('--flatten-components')
  fi

  if [ "${NPM_SHORT_PURLS}" = true ]; then
    SWITCHES+=('--short-PURLs')
  fi

  if [ "${NPM_OUTPUT_REPRODUCIBLE}" = true ]; then
    SWITCHES+=('--output-reproducible')
  fi

  if [ -n "${NPM_SPEC_VERSION}" ]; then
    SWITCHES+=("--spec-version" "${NPM_SPEC_VERSION}")
  fi

  if [ -n "${NPM_MC_TYPE}" ]; then
    SWITCHES+=("--mc-type" "${NPM_MC_TYPE}")
  fi

  if [ -n "${NPM_OMIT}" ]; then
    SWITCHES+=("--omit" "${NPM_OMIT}")
  fi

  if [ -n "${NPM_OUTPUT_FORMAT}" ]; then
    SWITCHES+=("--output-format" "${NPM_OUTPUT_FORMAT}")
  fi

  echo "the following switches will be used"
  echo "${SWITCHES[@]}"
}

unknown_project_format() {
  echo "ERROR: unknown project format"
  echo "currently only node/npm based projects are supported"
  exit 1
}

generate_cyclonedx_sbom() {
  if [ -f "package.json" ]; then
    echo "package.json file found. Generating sBOM for node/npm based projects"
    generate_cyclonedx_sbom_for_npm_project
  else
    unknown_project_format
  fi
}
