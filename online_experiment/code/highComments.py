def heapify(arr, n, i):
    largest = i  # Initialize largest as root
    l = 2 * i + 1  # left = 2*i + 1
    r = 2 * i + 2  # right = 2*i + 2

    # See if left child of root exists and is
    # greater than root
    if l < n and arr[i] < arr[l]:
        largest = l

    # See if right child of root exists and is
    # greater than root
    if r < n and arr[largest] < arr[r]:
        largest = r

    # Change root, if needed
    if largest != i:
        arr[i], arr[largest] = arr[largest], arr[i]  # swap

        # Heapify the root.
        heapify(arr, n, largest)

# The main function to sort an array of given size
def heapSort(arr):
    n = len(arr)

    # Build a maxheap.
    for i in range(n, -1, -1):
        heapify(arr, n, i)

    # One by one extract elements
    for i in range(n - 1, 0, -1):
        arr[i], arr[0] = arr[0], arr[i]
        heapify(arr, i, 0)


def highest(arr):
    m = max(arr)  # Storing maximum value
    if m < 1:
        # In case all values in our array are negative
        return 1
    if len(arr) == 1:
        # If it contains only one element
        return 2 if arr[0] == 1 else 1
    l = [0] * m
    for i in range(len(arr)):
        if arr[i] > 0:
            if l[arr[i] - 1] != 1:
                # Changing the value status at the index of our list
                l[arr[i] - 1] = 1
    for i in range(len(l)):

        # Encountering first 0, i.e, the element with least value
        if l[i] == 0:
            # return lowest non existing integer
            return i
    # In case all values are filled between 1 and m
    return i + 2


if __name__ == '__main__':
    # array with integers to be sorted
    arr = [5,3,1,3,6,7,9,11,16,7,32,8,16,2,4]
    # sorting function
    heapSort(arr)
    print("Highest non existing positive integer", highest(arr))



