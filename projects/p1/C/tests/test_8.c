
#include <stdio.h>

int compare(float a, float b, float epsilon) {
  return (a - b) < epsilon;
}

float test_8(float a, float b, float c, float d,
	     float e, float f, float g, float h);

float test_8_tester(float a, float b, float c, float d,
		    float e, float f, float g, float h)
{
  return b + f;
}

int main()
{

  for(int i=0; i<100; i++)
    {
      float ret = test_8(i,i+2,i*2,i*3,i,i+1,0,1);
      float sol = test_8_tester(i,i+2,i*2,i*3,i,i+1,0,1);
      if ( !compare(ret,sol,0.0001) ) {
	printf("test_7(%d) should be %f, but got %f.\n",i,sol,ret);
	return 1;
      }

    }
    
  return 0;
}



