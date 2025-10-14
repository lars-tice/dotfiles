#!/usr/bin/env python3
"""Test file for debugging functionality in Neovim."""

def calculate_factorial(n):
    """Calculate factorial of a number recursively."""
    if n < 0:
        raise ValueError("Factorial is not defined for negative numbers")
    elif n == 0 or n == 1:
        return 1
    else:
        result = n * calculate_factorial(n - 1)
        return result

def process_list(numbers):
    """Process a list of numbers and return their factorials."""
    results = []
    for num in numbers:
        try:
            fact = calculate_factorial(num)
            results.append(f"Factorial of {num} is {fact}")
        except ValueError as e:
            results.append(f"Error for {num}: {str(e)}")
    return results

def main():
    """Main function to test debugging."""
    # Test data
    test_numbers = [5, 3, -1, 0, 7, 10]
    
    print("Starting factorial calculations...")
    print(f"Input numbers: {test_numbers}")
    
    # Process the numbers
    results = process_list(test_numbers)
    
    # Print results
    print("\nResults:")
    for result in results:
        print(f"  - {result}")
    
    # Test with a specific number
    special_number = 6
    print(f"\nSpecial calculation for {special_number}:")
    factorial = calculate_factorial(special_number)
    print(f"The factorial is: {factorial}")
    
    # Test error handling
    print("\nTesting error handling:")
    try:
        calculate_factorial(-5)
    except ValueError as e:
        print(f"Caught expected error: {e}")

if __name__ == "__main__":
    main()