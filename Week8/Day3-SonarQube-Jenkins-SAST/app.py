def add(a, b):
    return a + b

def bad_function(x):
    # example of bad pattern just for sonar to flag (unused variable etc.)
    unused = 123
    if x == None:
        return 0
    return x * 2

if __name__ == "__main__":
    print(add(2, 3))
