from os import getenv
from pprint import pprint

from requests import post

if __name__ == '__main__':
    TRAVIS_BRANCH = getenv('TRAVIS_BRANCH')
    TRAVIS_BUILD_ID = getenv('TRAVIS_BUILD_ID')
    TRAVIS_BUILD_NUMBER = getenv('TRAVIS_BUILD_NUMBER')
    TRAVIS_TEST_RESULT = int(getenv('TRAVIS_TEST_RESULT'))
    TRAVIS_EVENT_TYPE = getenv('TRAVIS_EVENT_TYPE')

    TRAVIS_COMMIT = getenv('TRAVIS_COMMIT')
    TRAVIS_COMMIT_MESSAGE = getenv('TRAVIS_COMMIT_MESSAGE')
    TRAVIS_REPO_SLUG = getenv('TRAVIS_REPO_SLUG')

    TRAVIS_PULL_REQUEST = getenv('TRAVIS_PULL_REQUEST')
    TRAVIS_PULL_REQUEST_BRANCH = getenv('TRAVIS_PULL_REQUEST_BRANCH')
    TRAVIS_PULL_REQUEST_SHA = getenv('TRAVIS_PULL_REQUEST_SHA')
    TRAVIS_PULL_REQUEST_SLUG = getenv('TRAVIS_PULL_REQUEST_SLUG')

    DISCORD_WEBHOOK = getenv('DISCORD_WEBHOOK')
    BUILD_URL = f'{getenv("BUILD_URL")}/{TRAVIS_BUILD_ID}'
    noun = 'succeeded' if TRAVIS_TEST_RESULT == 0 else 'failed'
    color = 0x1660A5 if TRAVIS_TEST_RESULT == 0 else 0xff0000
    repo = f'https://github.com/{TRAVIS_REPO_SLUG}'
    fields = [
        ('Branch', TRAVIS_BRANCH, True),
        ('Commit Message', TRAVIS_COMMIT_MESSAGE, True),
        ('Repo', repo, True)
    ]
    if TRAVIS_PULL_REQUEST != 'false' and TRAVIS_PULL_REQUEST:
        extra = [
            ('Pull Request', TRAVIS_PULL_REQUEST, False),
            ('Pull Request Branch', TRAVIS_PULL_REQUEST_BRANCH, True),
            ('Pull Request Repo',
             f'[PR Repo](https://github.com/{TRAVIS_PULL_REQUEST_SLUG})',
             True)
        ]
        for n, v, i in extra:
            if v:
                fields.append((n, v, i))
    des = f'Build triggered by **{TRAVIS_EVENT_TYPE}**'
    if TRAVIS_COMMIT:
        des = f'{des} on [commit]({repo}/commit/{TRAVIS_COMMIT})'
    embed = {
        'title': f'Travis CI build #{TRAVIS_BUILD_NUMBER} **{noun}**',
        'type': 'rich',
        'description': des,
        'url': BUILD_URL,
        'color': color,
        'fields': [{'name': f[0], 'value': f[1], 'inline': f[2]}
                   for f in fields if f[1]]
    }
    pprint(embed)
    resp = post(DISCORD_WEBHOOK, json={'embeds': [embed]})
    pprint(resp.content)