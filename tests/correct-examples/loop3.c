main(){
    int a0 = 0;
    int stdout = 1;
    int stdout2 = 1;
    int a1, a2;
    while (1)
    {
        a1 = read_switch(1);
        a2 = read_switch(2);
        printf(stdout2, a2 * 16 + a1);
        printf(stdout, a0);
        a0 = a0 + 1;
    }
}