main(){
    // printf(1,17);
    int a = 7;
    int *a_ptr;
    printf(1, &a); // 4
    a_ptr = &a;
    printf(1, a_ptr); // 4
    *a_ptr = 3;
    // *a_ptr = 9;
    // int a2 = a_ptr;
    // int stdout = 1;
    printf(1, &a_ptr); // 8
    printf(1, a_ptr); // 4
    printf(1, *a_ptr); //3
    printf(1, a); //3
}