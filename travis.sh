#!/bin/bash
repo=""
if [ ! -z "$TRAVIS_REPO_SLUG" -a "$TRAVIS_REPO_SLUG" != " " ]; then
  repo="https://github.com/${TRAVIS_REPO_SLUG}"
fi

des="Build triggered by **${TRAVIS_EVENT_TYPE}**"
if [ ! -z "$TRAVIS_COMMIT" -a "$TRAVIS_COMMIT" != " " ]; then
  des+=" on [commit](${repo}/commit/${TRAVIS_COMMIT})"
fi

noun="failed"
color="14370117" #brick_red #db4545
if [ "$TRAVIS_TEST_RESULT" == "0" ]; then
  noun="succeeded"
  color="3779158" #turf_green #39AA56
fi

title="${TRAVIS_REPO_SLUG} build #${TRAVIS_BUILD_NUMBER} **${noun}**"

username="Travis CI"

all_travis_logos=( TravisCI-Mascot-1 TravisCI-Mascot-2 TravisCI-Mascot-3 TravisCI-Mascot-4 TravisCI-Mascot-grey TravisCI-Mascot-blue TravisCI-Mascot-red TravisCI-Mascot-pride TravisCI-Mascot-pride-4 Tessa-1 Tessa-2 Tessa-3 Tessa-4 Tessa-pride Tessa-pride-4 )
logo_idx=$[ RANDOM % 15 ]

avatar_url="https://travis-ci.com/images/logos/${all_travis_logos[logo_idx]}.png"

res="{\"username\": \"${username}\", \"avatar_url\": \"${avatar_url}\", \"embeds\": [{\"title\": \"${title}\", \"color\": ${color}, \"description\": \"${des}\", \"url\": \"${BUILD_URL}/${TRAVIS_BUILD_ID}\""

fields=""
if [ ! -z "$TRAVIS_BRANCH" -a "$TRAVIS_BRANCH" != " " ]; then
  fields+="{\"name\": \"Branch\", \"value\": \"${TRAVIS_BRANCH}\", \"inline\": true},"
fi

if [ ! -z "$TRAVIS_COMMIT_MESSAGE" -a "$TRAVIS_COMMIT_MESSAGE" != " " ]; then
  fields+="{\"name\": \"Commit Message\", \"value\": \"${TRAVIS_COMMIT_MESSAGE}\", \"inline\": true},"
fi

if [ ! -z "$repo" -a "$repo" != " " ]; then
  fields+="{\"name\": \"Repo\", \"value\": \"${repo}\", \"inline\": true},"
fi

if [ ! -z "$TRAVIS_PULL_REQUEST" -a "$TRAVIS_PULL_REQUEST" != " " -a "$TRAVIS_PULL_REQUEST" != "false" ]; then
  fields+="{\"name\": \"Pull Request\", \"value\": \"${TRAVIS_PULL_REQUEST}\", \"inline\": false},"
  if [ ! -z "$TRAVIS_PULL_REQUEST_BRANCH" -a "$TRAVIS_PULL_REQUEST_BRANCH" != " " ]; then
    fields+="{\"name\", \"Pull Request Branch\", \"value\": \"${TRAVIS_PULL_REQUEST_BRANCH}\", \"inline\": true},"
  fi

  if [ ! -z "$TRAVIS_PULL_REQUEST_SLUG" -a "$TRAVIS_PULL_REQUEST_SLUG" != " " ]; then
    fields+="{\"name\", \"Pull Request Repo\", \"value\": \"[PR Repo](https://github.com/${TRAVIS_PULL_REQUEST_SLUG})\", \"inline\": true},"
  fi
fi

if [[ $fields == *, ]]; then
  fields=${fields: : -1}
fi

if [ ! -z "$fields" -a "$fields" != " " ]; then
  res+=", \"fields\": [${fields}]"
fi
res+="}]}"
echo $res > res.json
curl -X POST -H "Content-Type: application/json" -d @res.json $DISCORD_WEBHOOK
