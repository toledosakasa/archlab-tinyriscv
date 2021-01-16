#include <stdio.h>

unsigned in;
unsigned o1,o2,o3,o4,o5;
unsigned A,B,C,D,E;
unsigned W[80];

unsigned f(unsigned i){
    if(i<20)
        return ((B&C)|((~B)&D));
    else if (i<40)
        return (B^C^D);
    else if (i<60)
        return ((B&C)|(B&D)|(C&D));
    else 
        return (B^C^D);
}

unsigned K(unsigned i){
    if(i<20)
        return 0x5A827999;
    else if (i<40)
        return 0x6ED9EBA1;
    else if (i<60)
        return 0x8F1BBCDC;
    else 
        return 0xCA62C1D6;
}

void sha1(){
    W[0] = in;
    W[1] = 0x80000000;
    W[15] = 32;
    for(unsigned i=2;i<15;i++)
        W[i] = 0;
    for(unsigned i=16;i<80;i++)
    {
        unsigned tmp = W[i-3]^W[i-8]^W[i-14]^W[i-16];
        W[i] = (tmp<<1)|(tmp>>31);
    }
    A = 0x67452301;
    B = 0xEFCDAB89;
    C = 0x98BADCFE;
    D = 0x10325476;
    E = 0xC3D2E1F0;
    for(unsigned i=0;i<80;i++){
        unsigned tmp = ((A<<5)|(A>>27))+f(i)+E+W[i]+K(i);
        E = D;
        D = C;
        C = (B<<30)|(B>>2);
        B = A;
        A = tmp;
        printf("i = %d, A = %x, B = %x, C = %x, D = %x, E = %x, W = %x\n",i+1,A,B,C,D,E,W[i]);
    }

}


int main()
{
    in = 0x3c3c3c3c;
    sha1();
    A = 0x67452301 + A;
    B = 0xEFCDAB89 + B;
    C = 0x98BADCFE + C;
    D = 0x10325476 + D;
    E = 0xC3D2E1F0 + E;
    printf("%x%x%x%x%x\n",A,B,C,D,E);
    return 0;
}