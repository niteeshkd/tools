#!/usr/bin/env python3
import sys

def main():
    filepath=sys.argv[1]
    print(f"file: {filepath}")

    with open(filepath, encoding="utf-8") as f: 
        data = f.read()
        print(data)

if __name__ == "__main__":
    main()
