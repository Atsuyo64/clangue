main()
{
    // int stdout = 1;
    int a, b, c;
    // int bit1,bit2,bit3,bit4,bit5,bit6,bit7,bit8;
    b = 0;
    a = 1;
    int dummy;
    while (1)
    {
        while(read_switch(15)) {dummy=1;}
        printf(1,b);
        printf(2,a);
        c = a + b;
        b = a;
        a = c;

        while(1-read_switch(15)) {dummy=2;}
        int guess = read_switch(0)+2*read_switch(1)+4*read_switch(2)+8*read_switch(3)+16*read_switch(4)+32*read_switch(5)+64*read_switch(6)+128*read_switch(7);

        if(guess-a){
            //loose
            printf(2,255);
        } else {
            //win
            printf(2,102);
        }
        printf(1, a);
    }
}