import os
import sys
import subprocess
from pathlib import Path


def main():
    args = sys.argv
    filename = args[1]
    filename_base = os.path.splitext(filename)[0]
    dirname = args[2]
    if not Path(dirname).exists():
        subprocess.run("md " + dirname, shell=True)
    subprocess.run("copy " + filename + " " + dirname + "\\tmp.tex", shell=True)
    os.chdir("out")
    subprocess.run(
        "uplatex -interaction=nonstopmode -kanji=utf8 " + "tmp.tex",
        shell=True,
    )
    subprocess.run("upbibtex " + "tmp", shell=True)
    for i in os.listdir(os.getcwd()):
        if os.path.isfile(i):
            if i.startswith("tmp"):
                subprocess.run(
                    "copy " + i + " " + filename_base + os.path.splitext(i)[1],
                    shell=True,
                )
    os.chdir("..")


if __name__ == "__main__":
    main()
