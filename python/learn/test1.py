def add(a: int, b: int) -> int:
    return a + b

def main():
    import argparse
    parser = argparse.ArgumentParser(description="Add two integers")
    parser.add_argument("a", type=int, help="first integer")
    parser.add_argument("b", type=int, help="second integer")
    args = parser.parse_args()
    print("values=", add(args.a, args.b))

if __name__ == "__main__":
    main()