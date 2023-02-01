#include <stdio.h>

int compare(float a, float b, float epsilon) {
  return (a - b) < epsilon;
}
float test_6(float a);

float solution_test_6(float a)
{
  float b = a + 1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9 + 10;
  float c = b * 1 * 2 * 3 * 4 * 5 * 6;
  return c;
}
int main()
{

  for(int i=-100; i<100; i++)
    {
      float ret = test_6(i);
      if ( !compare(ret,solution_test_6(i),0.0001) ) {
	printf("test_6(%d) should be %f, but got %f.\n",i,solution_test_6(i),ret);
	return 1;
      }

    }
    
  return 0;
}
