import os
css_path = os.path.join(os.path.dirname(__file__), "console.css")
content = open(css_path + ".b64tmp", "r").read()
import base64
decoded = base64.b64decode(content).decode("utf-8")
with open(css_path, "w", encoding="utf-8") as out:
    out.write(decoded)
print("Written", len(decoded), "bytes")
os.remove(css_path + ".b64tmp")
os.remove(__file__)
