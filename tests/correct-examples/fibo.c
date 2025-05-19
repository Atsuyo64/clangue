main()
{
    int stdout = 1;
    int stdout2 = 2;
    int a1, a2, b1, b2, c1, c2;
    a1 = 1;
    while (1)
    {
        c1 = a1 + b1;
        c2 = a2 + b2;
        b1 = a1;
        b2 = a2;
        int res1, res2;
        int cop1, cop2;
        cop1 = a1;
        cop2 = c1;
        if (cop1)
            res1 = 1;
        else
            res1 = 0;
        if (cop2)
            res2 = 1;
        else
            res2 = 0;

        while (res1 * res2) // cop1 && cop2
        {
            cop1 = cop1 - 1;
            cop2 = cop2 - 1;
            if (cop1)
                res1 = 1;
            else
                res1 = 0;
            if (cop2)
                res2 = 1;
            else
                res2 = 0;
        }

        //cop1 > cop2
        if(cop1){
             c2 = c2 + 1;
        }

        a1 = c1;
        a2 = c2;
        printf(stdout2, a2);
        printf(stdout, a1);
    }
}

// int b1;
// int b2;
// int a1;
// int a2;

// int c1,c2;

// c1 = a1 + b1;
// if(c1 < a1 or c1 < b1){
//     carry = 1;
// }

// a || b
// <=>
// int res1,res2;
// if(a) res1=1; else res1 = 0;
// if(b) res2=1; else res2 = 0;
// if(res1+res2)
//     do_something;

// c < a <=> 0 < a-c <=> 

// c := (a+b) % 256; 256 - a < b; 

//a = 063d; b = 03db; 

/*
Expected:

0th Fibonacci:1 (0001 hex)
1st Fibonacci:1 (0001 hex)
2nd Fibonacci:2 (0002 hex)
3rd Fibonacci:3 (0003 hex)
4th Fibonacci:5 (0005 hex)
5th Fibonacci:8 (0008 hex)
6th Fibonacci:13 (000d hex)
7th Fibonacci:21 (0015 hex)
8th Fibonacci:34 (0022 hex)
9th Fibonacci:55 (0037 hex)
10th Fibonacci:89 (0059 hex)
11th Fibonacci:144 (0090 hex)
12th Fibonacci:233 (00e9 hex)
13th Fibonacci:377 (0179 hex)
14th Fibonacci:610 (0262 hex)
15th Fibonacci:987 (03db hex)
16th Fibonacci:1597 (063d hex)
17th Fibonacci:2584 (0a18 hex)
18th Fibonacci:4181 (1055 hex)
19th Fibonacci:6765 (1a6d hex)
20th Fibonacci:10946 (2ac2 hex)
21th Fibonacci:17711 (452f hex)
22nd Fibonacci:28657 (6ff1 hex)
23rd Fibonacci:46368 (b520 hex)
*/