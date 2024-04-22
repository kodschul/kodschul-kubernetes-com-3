
import sys

name = sys.argv[1]

with open("hello.txt", "w+") as f:
    f.write(f"Hi {name}!")
