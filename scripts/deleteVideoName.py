import os
import sys
import codecs


def process(path):
    files = [x for x in os.listdir(path) if x.endswith('txt')]

    for file in files:
        file = os.path.join(path, file)
        print("Converting %s" % file)
        os.system("sed -i -e 's/.*\///g' %s" % file)
        os.system("sed -i -e 's/.jpg//g' %s" % file)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Error! One more parameters need.")
        sys.exit()

    path = sys.argv[1]
    process(path)
    print("Done!")
