import os, sys
d = os.path.dirname(os.path.abspath(__file__))
p = os.path.join(d, "console.css")
# Read from stdin
import base64
b = sys.stdin.read().strip()
c = base64.b64decode(b).decode("utf-8")
with open(p, "w", encoding="utf-8") as out:
    out.write(c)
print(f"Written {len(c)} chars")
