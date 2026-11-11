# Zip a folder into a .mcpack. Python's zipfile writes forward slashes in entry
# names, which .NET's ZipFile on Windows PowerShell does not always do.
import os
import sys
import zipfile


def main():
    if len(sys.argv) != 3:
        print("usage: make-mcpack.py <source-dir> <out.mcpack>", file=sys.stderr)
        return 2

    src, out = sys.argv[1], sys.argv[2]
    if not os.path.isdir(src):
        print(f"source folder not found: {src}", file=sys.stderr)
        return 1
    if not os.path.isfile(os.path.join(src, "manifest.json")):
        print(f"manifest.json missing in {src}", file=sys.stderr)
        return 1

    if os.path.exists(out):
        os.remove(out)

    count = 0
    with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
        for root, _dirs, files in os.walk(src):
            for name in files:
                full = os.path.join(root, name)
                rel = os.path.relpath(full, src).replace("\\", "/")
                archive.write(full, rel)
                count += 1

    size = os.path.getsize(out)
    print(f"mcpack: {out} ({size / 1024:.0f} KB, {count} files)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
