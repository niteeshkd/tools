import string

# This is a test file for vscode-terminal
string1="abc 234 xyz"

string2="".join([c for c in string1 if c in string.ascii_letters])
print(string2)
print(string1.startswith("a"))
