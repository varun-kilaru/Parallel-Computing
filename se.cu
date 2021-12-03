#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>

long long getFileSize(char *name){

	FILE *file;
	file = fopen(name, "r");
	//printf("2\n");
	if (file == NULL)
    {
        printf("File is not available \n");
        return 0;
    }
    long long prev=ftell(file);
    //printf("3\n");
    fseek(file, 0L, SEEK_END);
    //printf("4\n");
    long long sz=ftell(file);
    //printf("5\n");
    fseek(file,prev,SEEK_SET);
    //printf("6\n"); //go back to where we were
    fclose(file);
    //printf("7\n");
    return sz;
}

void search(char* data, int data_len, char* pat, int pat_len, int offset)
{
   int M = pat_len;
   int N = offset;
   //printf("%s", data);
   int i, j;
   int count = 0;
   int found = 0;
   for(i = 0; i < N - M + 1 ; i++) {
     found = 1;
     for(j = 0; j < M; j++) {
       if(data[i+j] != pat[j]) {
         found = 0;
         break;
       }
     }
     if(found) {
       count++;
       i = i + M -1;
       //printf("at index: %d\n",i);
     }
   }
   printf("frequency of \"%s\" in data: %d  ",pat, count);
}

int main(){

    clock_t t;
    t = clock();

	FILE *file;
	file = fopen("largeData.txt", "r");
	//printf("1\n");
	long long size = getFileSize("largeData.txt");
	//printf("8\n");

	//printf("%d\n", 1000000);
	long long i = 0;
	char *data = (char*)malloc(size*sizeof(char));
	//printf("9\n");
    char ch;
    if (file == NULL)
    {
        printf("File is not available \n");
    }
    else
    {
        //printf("10\n");
        while ((ch = fgetc(file)) != EOF)
        {
            data[i] = ch;
            i++;
        }
        //printf("11\n");
    }

    //for(long long j=0;j<size;j++)
    	//printf("%c", data[j]);
    //printf("12\n");
    char pat[100] = "Angina  n. (in full angina pectoris) chest pain brought on by exertion, caused by an inadequate bl";
    int pat_s = strlen(pat);
    search(data, size, pat, pat_s, size);
    fclose(file);
    //printf("13\n");

    t = clock() - t;
    double time_taken = ((double)t)/CLOCKS_PER_SEC; // in seconds

    printf("\nIt took %f seconds for serial code to execute \n", time_taken);

    return 0;
}

