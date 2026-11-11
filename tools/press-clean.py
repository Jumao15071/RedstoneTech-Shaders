# Post-process lazurite unpacked GLSL after the spirv round-trip:
#   1. drop layout(...) qualifiers (spirv-cross now emits layout(location=..,binding=..),
#      which the old press regex-replace.py could not match)
#   2. force highp float default (spirv-cross emits mediump)
#   3. minify: comments, indentation, spaces around punctuation, double minus
import os
import re
import sys

LAYOUT = re.compile(r"layout\s*\([^)]*\)\s*")
MEDIUMP_FLOAT = re.compile(r"precision\s+mediump\s+float\s*;")
COMMENT = re.compile(r"\/\/.*|\/\*[\s\S]*?\*\/")
TRAILING = re.compile(r"[ \t]+$", re.M)
LEADING = re.compile(r"^\s+", re.M)
PUNCT_SPACE = re.compile(r"(?<=[(){}\[\]<>=+\-*/|&?:;,])\s+|\s+(?=[(){}\[\]<>=+\-*/|&?:;,])")
DOUBLE_MINUS = re.compile(r"--")
DECIMAL_TAIL = re.compile(r"(?<=\d\.\d{7})\d+")
DECIMAL_ZERO = re.compile(r"(?<=\d\.\d\d)(0+)(?=[^\d])")


def clean(text):
    text = LAYOUT.sub("", text)
    text = MEDIUMP_FLOAT.sub("precision highp float;", text)
    text = COMMENT.sub("", text)
    text = TRAILING.sub("", text)
    text = LEADING.sub("", text)
    text = PUNCT_SPACE.sub("", text)
    text = DECIMAL_TAIL.sub("", text)
    text = DECIMAL_ZERO.sub("", text)
    text = DOUBLE_MINUS.sub("- -", text)
    return text


def main(root):
    changed = 0
    for base, _dirs, files in os.walk(root):
        for name in files:
            if not name.endswith(".glsl"):
                continue
            path = os.path.join(base, name)
            with open(path, "r", encoding="utf-8") as f:
                text = f.read()
            new = clean(text)
            if new != text:
                with open(path, "w", encoding="utf-8", newline="") as f:
                    f.write(new)
                changed += 1
    print(f"cleaned {changed} glsl files under {root}")


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "src")
