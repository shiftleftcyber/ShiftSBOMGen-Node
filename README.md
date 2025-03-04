# ShiftSBOM-Node

[![SonarQube Cloud](https://sonarcloud.io/images/project_badges/sonarcloud-highlight.svg)](https://sonarcloud.io/summary/new_code?id=ccideas1_cyclonedx-npm-pipe)

[![Bugs](https://sonarcloud.io/api/project_badges/measure?project=ccideas1_cyclonedx-npm-pipe&metric=bugs)](https://sonarcloud.io/summary/new_code?id=ccideas1_cyclonedx-npm-pipe)
[![Code Smells](https://sonarcloud.io/api/project_badges/measure?project=ccideas1_cyclonedx-npm-pipe&metric=code_smells)](https://sonarcloud.io/summary/new_code?id=ccideas1_cyclonedx-npm-pipe)
[![Duplicated Lines (%)](https://sonarcloud.io/api/project_badges/measure?project=ccideas1_cyclonedx-npm-pipe&metric=duplicated_lines_density)](https://sonarcloud.io/summary/new_code?id=ccideas1_cyclonedx-npm-pipe)

![Build Badge](https://img.shields.io/bitbucket/pipelines/ccideas1/cyclonedx-npm-pipe/main)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/shiftleftcyber/cyclonedx-npm-pipe)

ShiftSBOM-Node is a pure client-side Bitbucket Pipe that generates a CycloneDX-compliant Software Bill of Materials
(SBOM) for Node.js/npm projects. No subscriptions, server access, or API keys are required.

The official copy this project is hosted on [Bitbucket](https://bitbucket.org/ccideas1/cyclonedx-npm-pipe/src/main/).
In order to reach a diverse audience a copy of the repo also exists in
[GitHub](https://github.com/ccideas/cyclonedx-npm-pipe).
It is recommended to submit Pull Requests to the Bitbucket copy, however submissions to either copy
will be synced.

## YAML Definition

The following is an example of a bitbucket pipeline which installs npm dependencies and caches those
dependencies in one step then uses those cached depdencies in the next step to build a CycloneDX
sBOM. The following code snip would need to be added to the `bitbucket-pipelines.yml` file

```yaml
pipelines:
  default:
    - step:
        name: Build and Test
        caches:
          - node
        script:
          - npm install
          - npm test
    - step:
        name: Gen CycloneDX sBom
        caches:
          - node
        script:
          - pipe: docker://ccideas/cyclonedx-npm-pipe:3.0.1
            variables:
              IGNORE_NPM_ERRORS: 'true' # optional
              NPM_SHORT_PURLS: 'true' # optional
              NPM_OUTPUT_FORMAT: 'json' # optional
              NPM_PACKAGE_LOCK_ONLY: 'false' # optional
              NPM_SPEC_VERSION: '1.6' # optional
              OUTPUT_DIRECTORY: 'build' # optional # this dir should be archived by the pipeline
        artifacts:
          - build/*
```

## Variables

| Variable                  | Usage                                                               | Options                         | Default       |
| ---------------------     | -----------------------------------------------------------         | -----------                     | -------       |
| IGNORE_NPM_ERRORS         | Used to ignore any npm errors when generating the report            | true, false                     | false         |
| NPM_FLATTEN_COMPONENTS    | Used to specify if the components should be flattened               | true, false                     | false         |
| NPM_SHORT_PURLS           | Used to specify if qualifiers from PackageURLs should be shortened  | true, false                     | false         |
| NPM_OUTPUT_REPRODUCIBLE   | Used to specify if the output should be reproducible                | true, false                     | false         |
| NPM_SPEC_VERSION          | Used to specify the version of the CycloneDX spec                   | 1.2, 1.3, 1.4, 1.5, 1.6         | 1.6           |
| NPM_MC_TYPE               | Used to specify the type of main component                          | application, firmware, library  | application   |
| NPM_OMIT                  | Used to omit specific dependency types                              | dev, optional, peer             | none          |
| NPM_OUTPUT_FORMAT         | Used to specify output format of the sBOM                           | json, xml                       | json          |
| NPM_PACKAGE_LOCK_ONLY     | Used to use only the package-lock.json file to find dependencies    | true, false                     | false         |
| OUTPUT_DIRECTORY          | Used to specify the directory to place all output im                | directory name                  | sbom_output   |

## Details

Generates a CycloneDX compliant Software Bill of Materials
for a node/npm project. The generated sBOM will be created in the
sbom-output directory and be named `${BITBUCKET_REPO_SLUG}-sbom.json`

## Prerequisites

npm dependencies must be installed first. It is advised to install npm dependencies
in one step then archive them, so they can be read by the pipe. See the example below.

## Example

A working pipeline for the popular [auditjs](https://www.npmjs.com/package/auditjs)
tool has been created as an example. The pipeline in
this fork of the [auditjs](https://www.npmjs.com/package/auditjs) tool will install the required
dependencies then generate a CycloneDX sBOM containing all the ingredients which make up the
product.

* [Repository Link](https://bitbucket.org/ccideas1/fork-auditjs/src/main/)
* [Link to bitbucket-pipelines.yml](https://bitbucket.org/ccideas1/fork-auditjs/src/main/bitbucket-pipelines.yml)
* [Link to pipeline](https://bitbucket.org/ccideas1/fork-auditjs/pipelines/results/4)

## Support

If you'd like help with this pipe, or you have an issue, or a feature request,
[let us know](https://github.com/ccideas/cyclonedx-npm-pipe/issues).

If you are reporting an issue, please include:

the version of the pipe
relevant logs and error messages
steps to reproduce

## Credits

This Bitbucket pipe is a collection and integration of the following open source tools

* [cyclonedx-npm](https://github.com/CycloneDX/cyclonedx-node-npm)

A big thank-you to the teams and volunteers who make these amazing tools available
