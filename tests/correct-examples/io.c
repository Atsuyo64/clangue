main(){
    int a1, a2, a3, a4;
    int stdout = 1;
    while (1)
    {
        a1 = read_switch(1);
        a2 = read_switch(2);
        // a3 = read_switch(3);
        // a4 = read_switch(4);
        printf(stdout, /*1000*a4 + 100*a3 +*/ 16*a2 + a1);
    }
}