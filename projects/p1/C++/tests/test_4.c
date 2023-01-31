#include <stdio.h>

int compare(float a, float b, float epsilon) {
  return (a - b) < epsilon;
}

float test_4(float a);

int main()
{

  for(int i=-100; i<100; i++)
    {
      if (i==0) continue;
      float ret = test_4(i);
      if (!compare(ret, 1.0/i, 0.0001)) {
	printf("test_4(%d) should be %f, but got %f.\n",i,1.0/i,ret);
	return 1;
      }
    }
    
  return 0;
}

