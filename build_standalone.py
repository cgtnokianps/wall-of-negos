"""Embed the CGT logo directly in the agreement page."""

import base64
import os
import urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
SOURCE_PATH = os.path.join(HERE, "index.html")
CGT_LOGO_URL = "https://cloud.cgt.fr/public.php/dav/files/MNHkBG45DttSo4j"
CGT_LOGO_DECLARATION = (
    "const CGT_LOGO_URL = 'https://cloud.cgt.fr/public.php/dav/files/"
    "MNHkBG45DttSo4j';"
)


def embed_cgt_logo(source):
    """Replace the external CGT logo URL with a base64 data URI."""
    if "data:image/svg+xml;base64," in source:
        return source

    request = urllib.request.Request(
        CGT_LOGO_URL,
        headers={"User-Agent": "Mozilla/5.0"},
    )
    with urllib.request.urlopen(request, timeout=20) as response:
        logo_data = base64.b64encode(response.read()).decode("ascii")

    embedded_logo = f"data:image/svg+xml;base64,{logo_data}"
    return source.replace(
        CGT_LOGO_DECLARATION,
        f"const CGT_LOGO_URL = '{embedded_logo}';",
        1,
    )


def main():
    with open(SOURCE_PATH, encoding="utf-8") as source_file:
        source = source_file.read()

    updated_page = embed_cgt_logo(source)
    with open(SOURCE_PATH, "w", encoding="utf-8") as output_file:
        output_file.write(updated_page)

    size_kb = os.path.getsize(SOURCE_PATH) // 1024
    print(f"Updated {os.path.basename(SOURCE_PATH)} ({size_kb} KiB)")


if __name__ == "__main__":
    main()
