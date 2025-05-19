main(){
    int a = 20;
    int dummy;
    printf(1,0xff);
    printf(2,0xff);
    while(read_switch(15)) {dummy=1;}
    int a1=(a<=20)+(a>=9)*2+(a<21)*4+(a>19)*8+(a==20)*16+(a!=21)*32;
    int a2=(a<=19)+(a>=90)*2+(a<20)*4+(a>20)*8+(a==21)*16+(a!=20)*32;
    printf(1,a1);
    printf(2,a2);
}