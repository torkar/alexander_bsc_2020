# function for heap tree
def heapify(arr, n, i):
    largest = i  # largest
    l = 2 * i + 1
    r = 2 * i + 2

    # compare left child
    if l < n and arr[i] < arr[l]:
        largest = l

    # compare right child
    if r < n and arr[largest] < arr[r]:
        largest = r

    # swap root
    if largest != i:
        arr[i], arr[largest] = arr[largest], arr[i]  # swap

        heapify(arr, n, largest)

# function for sorting
def heapSort(arr):
    n = len(arr)

    for i in range(n, -1, -1):
        heapify(arr, n, i)

    for i in range(n - 1, 0, -1):
        arr[i], arr[0] = arr[0], arr[i]
        heapify(arr, i, 0)


def highest(arr):
    m = max(arr) # max
    if m < 1:   # if negative
        return 1
    if len(arr) == 1: # if size 1
        return 2 if arr[0] == 1 else 1
    l = [0] * m
    for i in range(len(arr)):
        if arr[i] > 0:
            if l[arr[i] - 1] != 1:
                l[arr[i] - 1] = 1
    for i in range(len(l)):
        if l[i] == 0:
            # return lowest non existing integer
            return i

    return i + 2


if __name__ == '__main__':
    arr = [5,3,1,3,6,7,9,11,16,7,32,8,16,2]
    heapSort(arr)
    print("Highest non existing positive integer", highest(arr))



