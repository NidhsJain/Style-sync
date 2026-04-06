import urllib.request
import os

url = "https://raw.githubusercontent.com/flutter/flutter/master/examples/hello_world/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png"
out_path = "assets/icon/icon.png"

try:
    urllib.request.urlretrieve(url, out_path)
    print("Successfully downloaded placeholder icon.")
except Exception as e:
    print(f"Error: {e}")
