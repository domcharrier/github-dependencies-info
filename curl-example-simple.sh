#!/usr/bin/env bash
# Examples:
# - Query dependencies:
#   ./curl-example-simple.sh rapidsai cudf'
# - Query dependencies and then filter with yq:
#   ./curl-example-simple.sh rapidsai cudf | yq '.deps | map(select(.package_manager == "PIP"))'
# Prerequisites
# - jq tool must be installed (typically vail via OS package manager)
# - yq tool must be installed (typically avail via OS package manager)
# - Install github classic token with `public_repo` authorization
#   in your github account. The token below expires in 30 days (created: Jan 17 23).
# References:
# - https://til.simonwillison.net/github/dependencies-graphql-api
# - https://til.simonwillison.net/graphql/graphql-with-curl
OWNER=${1:-cupy}
REPO=${2:-cupy}
TOKEN=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

echo "deps:"
curl -s https://api.github.com/graphql -X POST \
-H "Authorization: Bearer ${TOKEN}" \
-H "Accept: application/vnd.github.hawkgirl-preview+json" \
-H "Content-Type: application/json" \
-d "$(jq -c -n --arg query "
{
  repository(owner:\"${OWNER}\", name:\"${REPO}\") {
    dependencyGraphManifests {
      edges {
        node {
          dependencies {
            nodes {
              id: packageName
              version: requirements
              has_deps: hasDependencies
              package_manager: packageManager
            }
          }
        }
      }
    }
  }
}" '{"query":$query}')" | \
  jq .data.repository.dependencyGraphManifests.edges[].node.dependencies.nodes[] | \
  yq -P -p=json | \
  grep -v "^---" | sed "s,^,  ,g" | sed "s,  id,- id,g" 
