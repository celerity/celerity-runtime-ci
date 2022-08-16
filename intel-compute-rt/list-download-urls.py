import json
import os
import sys

extensions = sys.argv[1:]
for a in json.load(sys.stdin):
    if os.path.splitext(a['name'])[1] in extensions:
        print(a['browser_download_url'])