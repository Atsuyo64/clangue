int func(int a,int b) {
    if(a) {
        if (b)
            printf(b);
        else {
            printf(a);
        }
    }
    return b;
}

main()

{
    const v,_U = 12;
    int a =0    ;
    func(a,55);

    while(a <= 12) {
        a = a<<1;
        a = a & 31; //0b11111 
    }
}