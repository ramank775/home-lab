from datetime import datetime
from hashlib import md5
import requests
import xmltodict
import json
import functools
import base64
import os
import sys


class Http:
    def __init__(self, url, headers={}):
        self.user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.47 Safari/537.36'
        self._raw_content = None
        self._url = url
        self._headers = {**{'User-Agent': self.user_agent}, **headers}

    def _execute_request(self, method="GET", headers={}, data=None):
        headers = {**self._headers, **headers}
        response = requests.request(
            method, self._url, headers=headers, data=data)
        self._raw_content = response.text
        if(response.status_code != 200):
            raise Exception(
                f"HTTP requests failed with status code {response.status_code}")
        return self._raw_content

    def get(self, headers={}):
        self._execute_request(headers=headers)

    def put(self, data, headers={}):
        self._execute_request(method="PUT", data=data, headers=headers)

    def get_json(self):
        content = json.loads(self._raw_content)
        return content

    def get_xml(self):
        content = xmltodict.parse(self._raw_content)
        return content


class GithubRepo:
    def __init__(self, repo, auth_token):
        self._repo = repo
        self._filePaths = {
            "featured_posts": "_data/featured_posts.json"
        }
        self._sha = {}
        self._auth_token = auth_token

    def _get_file_url(self, file):
        filename = self._filePaths[file]
        url = f"https://api.github.com/repos/{self._repo}/contents/{filename}"
        return url

    def _update_file(self, file, content, message):
        print(f"updating file on github {file}")
        url = self._get_file_url(file)
        encoded_content = base64.b64encode(
            content.encode('utf-8')).decode('utf-8')
        data = json.dumps({
            "message": message,
            "content": encoded_content,
            "sha": self._sha[file]
        })
        headers = {
            'Authorization': f'token {self._auth_token}',
            'Content-Type': 'application/json'
        }
        http_client = Http(url, headers=headers)
        http_client.put(data)
        response = http_client.get_json()
        return response

    def _get_file(self, file):
        url = self._get_file_url(file)
        http_client = Http(url)
        http_client.get()
        value = http_client.get_json()
        self._sha[file] = value["sha"]
        raw_content = base64.b64decode(value["content"].encode('utf-8'))
        content = json.loads(str(raw_content, 'utf-8'))
        return content

    def get_featured_posts(self):
        content = self._get_file("featured_posts")
        return content

    def update_featured_posts(self, posts):
        content = json.dumps(posts)
        response = self._update_file(
            "featured_posts",
            content,
            "[Feature Bot]: updated new featured posts"
        )
        self._sha["featured_posts"] = response["content"]["sha"]


class VisitorCounter:
    def __init__(self, namespace, endpoint):
        self._namespace = namespace
        self._endpoint = endpoint

    def _get_url(self, key):
        url = f"{self._endpoint}/count?namespace=${self._namespace}&page_id={key}&read=true"
        return url

    def count(self, key):
        url = self._get_url(key)
        http_client = Http(url)
        http_client.get()
        value = http_client.get_json()
        return value["value"]


def get_post_titles_from_RSS_feed(url):
    http_client = Http(url)
    http_client.get()
    feed = http_client.get_xml()
    titles = [x["title"]["#text"] for x in feed["feed"]["entry"]]
    return titles


def calc_featured_posts(post_titles, visitor_counts, count):
    posts = []
    for i in range(len(post_titles)):
        posts.append((post_titles[i], visitor_counts[i]))

    def compare(item1, item2):
        return item2[1] - item1[1]

    posts.sort(key=functools.cmp_to_key(compare))
    featured_posts = [x[0] for x in posts[:count]]
    return featured_posts


def get_config():
    CONFIG = {
        "rss_feed": os.environ.get("RSS_FEED", "https://blog.one9x.org/feed.xml"),
        "repo": os.environ.get("REPO_NAME", "one9x/blog"),
        "github_token": os.environ.get("GITHUB_TOKEN"),
        "visitor_namespace": os.environ.get("VISITOR_COUNTER_NAMESPACE", "one9x.post"),
        "no_of_featured_posts": os.environ.get("FEATURED_POSTS_COUNT", 2),
    }

    try:
        debug = sys.argv[1] == "debug"
        if debug:
            CONFIG["repo"] = "ramank775/blog-1"
            CONFIG["github_token"] = sys.argv[2]
    except:
        pass

    return CONFIG


def handleError(ex):
    print("Something went wrong", ex)
    endpoint = os.environ.get("ERROR_REPORTING_ENDPOINT")
    if endpoint:
        data = json.dumps({
            "name": "featured_posts cron",
            "error": str(ex)
        })
        headers = {
            "Content-Type": "application/json"
        }
        response = requests.request(
            "POST", endpoint, headers=headers, data=data)
        print("Error pushed to reporting endpoint with status code",
              response.status_code)

def calculate_score(post):
    # Define weights based on your priorities
    weight_date = 0.6
    weight_page_loads = 0.4
    decay_factor = 0.95  # Adjust as needed

    # Get current date and time
    current_date = datetime.now()

    # Calculate recency factor (example: days since publish date)
    days_since_publish = (current_date - post['publish_date']).days

    # Calculate the decayed page load count
    decayed_page_loads = post['page_loads'] * (decay_factor ** days_since_publish)

    # Calculate the score
    score = (weight_date * (1 / (1 + days_since_publish))) + (weight_page_loads * decayed_page_loads)

    return score


def main():
    CONFIG = get_config()
    titles = get_post_titles_from_RSS_feed(CONFIG["rss_feed"])

    visitor_counter = VisitorCounter(CONFIG["visitor_namespace"])
    counts = [visitor_counter.count(title) for title in titles]

    new_featured_posts = calc_featured_posts(
        titles, counts, CONFIG["no_of_featured_posts"])

    repo = GithubRepo(CONFIG["repo"], CONFIG["github_token"])
    old_featured_posts = repo.get_featured_posts()
    if not (json.dumps(new_featured_posts) == json.dumps(old_featured_posts)):
        print("updating new featured posts to github")
        print(new_featured_posts)
        repo.update_featured_posts(new_featured_posts)
    else:
        print("Nothing to update", old_featured_posts)


try:
    main()
    print("Successfully completed")
except Exception as ex:
    handleError(ex)
