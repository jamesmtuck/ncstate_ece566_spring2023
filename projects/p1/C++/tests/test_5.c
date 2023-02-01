#include <stdio.h>

int compare(float a, float b, float epsilon) {
  return (a - b) < epsilon;
}

float test_5(float a);

int main()
{

  for(int i=-100; i<100; i++)
    {
      if (i==0) continue;
      float ret = test_5(i);
      if (!compare(ret, -(float)i, 0.0001)) {
	printf("test_5(%d) should be %f, but got %f.\n",i,-(float)i,ret);
	return 1;
      }
    }
    
  return 0;
}


