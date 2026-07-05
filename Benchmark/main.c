int fib_array[10]; 

int main() {
    fib_array[0] = 0;
    fib_array[1] = 1;
    
    for(int i = 2; i < 10; i++) {
        fib_array[i] = fib_array[i-1] + fib_array[i-2];
    }
    
    return 0;
}