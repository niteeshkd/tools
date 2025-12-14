from datetime import datetime
from typing import List

# Generator
def fibonacci(n):
    a, b = 0, 1
    for _ in range(n):
        yield a
        a, b = b, a + b
#Decorator
def decorator_function(original_function):
    def wrapper_function(*args, **kwargs):
        print(f"[{datetime.now()}] Executing {original_function.__name__}")
        result = original_function(*args, **kwargs)
        print(f"[{datetime.now()}] Executing {original_function.__name__}")    
        return result
    return wrapper_function

@decorator_function
def calculate_statistics(numbers: List[int], *, scale=1):
    if not numbers:
        raise ValueError("The list of numbers is empty")
    
    total = sum(numbers) * scale
    avg = total / len(numbers)
    return {
        "total": total,
        "average": avg,
        "max": max(numbers) * scale,
        "min": min(numbers) * scale     
    }

# OOP: Base Class
class Employee:
    def __init__(self, name: str, position: str, salary: float):
        self.name = name
        self.position = position
        self.salary = salary

    def get_annual_salary(self) -> float:
        return self.salary * 12
    
    def __str__(self):
        return f"Employee(Name: {self.name}, Position: {self.position}, Salary: {self.salary})"

# OOP: Inheritance and Polymorphism
class Manager(Employee):
    def __init__(self, name: str, position: str, salary: float, bonus: float):
        super().__init__(name, position, salary)
        self.bonus = bonus
        
    def get_annual_salary(self) -> float:
        return self.salary * 12 + self.bonus
    
    def __str__(self):
        return f"Manager(Name: {self.name}, Position: {self.position}, Salary: {self.salary}, Bonus: {self.bonus})"  

#Context Manager
class FileManager:
    def __init__(self, filename: str, mode: str):
        self.filename = filename
        self.mode = mode
        self.file = None

    def __enter__(self):
        self.file = open(self.filename, self.mode)
        return self.file

    def __exit__(self, exc_type, exc_value, traceback):
        if self.file:
            self.file.close()

# main function 
def main():
    # Variables and Data types
    name = "Alice"
    age = 30
    is_active = True
    scores = [85, 90, 78, 92]
    unique_scores = set(scores)
    user_info = {"name": name, "age": age}

    # Control flow
    if age >= 18 and is_active:
        print(f"{name} is an active adult")

    #List comprehension
    squared_scores = [x **2 for x in scores if x > 80]
    print("Squared Scores:", squared_scores)

    #Lamda function
    add_five = lambda x: x + 5
    new_score = add_five(90)
    print("New Score after adding five:", new_score)

    #map function
    doubled_scores = list(map(lambda x: x * 2, scores))
    print("Doubled Scores:", doubled_scores)

    #filter function
    high_scores = list(filter(lambda x: x > 85, scores))
    print("High Scores:", high_scores)

    #Generators
    print("Generator:")
    print("Fibonacci sequence up to 7 terms:")
    #print(fibonacci(7))
    for num in fibonacci(7):
        print(num, end=" ")
    print()
    
    #Exception handling
    try:
        stats = calculate_statistics(scores, scale=2)
        print("Statistics:", stats)
    except ValueError as e:
        print("Error:", e)
    finally:
        print("Statistics calculation attempted.")

    #OOP
    emp = Employee("Bob", "Developer", 5000)
    mgr = Manager("Carol", "Team Lead", 7000, 15000)
    print(emp)
    print("Employee Annual Salary:", emp.get_annual_salary())
    print(mgr)
    print("Manager Annual Salary:", mgr.get_annual_salary())

    #File I/O with Context Manager
    with FileManager("testfile.txt", "w") as f:
        f.write("Hello, World!\n")
        f.write("This is a test file.\n")
    with FileManager("testfile.txt", "r") as f:
        content = f.read()
        print("File Content:\n", content)
        
if __name__ == "__main__":
    main()