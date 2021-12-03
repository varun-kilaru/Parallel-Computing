#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>


long long getFileSize(char *name){

    FILE *file;
    long long sz = 0;
    file = fopen(name, "r");
    if (file == NULL)
    {
        printf("File is not available \n");
        return 0;
    }
    else{
	long long prev=ftell(file);
        fseek(file, 0L, SEEK_END);
        sz=ftell(file);
	fseek(file,prev,SEEK_SET);
    }
    fclose(file);
    return sz;
}

__global__ void search(char* data, int data_len, char* pat, int pat_len, int offset, int* c)
{
   int tid = blockIdx.x * blockDim.x + threadIdx.x;
   //printf("ThreadId: %d\n", tid);
   int M = pat_len;
   int N = (tid + 1) * offset;
   //printf("\ntM: %d\t\tN: %d\t\tstart:%d\t\tM+N: %d", M, N, tid*offset, M+N);
   //printf("\nstart index: %d\t\tend index: %d", tid*offset, N + M);
   if(tid*offset <= data_len){
           //printf("\ndatalen: %d", data_len);
           //printf("\nM: %d\t\tN: %d\t\tstart:%d\t\tM+N: %d", M, N, tid*offset, M+N);
	   //printf("\nstart index: %d\t\tend index: %d", tid*offset, N + M);
	   int i, j;
	   int count = 0;
	   int found = 0;
	   for(i = tid*offset; i < N + 1; i++) {
	     found = 1;
	     for(j = 0; j < M; j++) {
               //printf("%d\t", i+j);
	       if(data[i+j] != pat[j]) {
		 found = 0;
		 break;
	       }
	   }
	   //printf("\n%daaaa", N*(M-1));
	     if(found) {
	       //atomicAdd(&count, 1);
	       count++;
	       i = i + M -1;
	       //printf("at index: %d\n",i);
	       //atomicAdd(&count, 1);
	     }
	   }
	   
	   //printf("\n%d  ",count);
	   //cuPrintf()
	   //*c += count;
	   atomicAdd(c, int(count));
           //printf("%d", c);
    }
}


int main(){

    	clock_t t;
    	t = clock();

	long long size = getFileSize("largeData.txt");
	printf("%lld", size);
	long long i = 0;
	char *data = (char *)malloc(size*sizeof(char));
	char ch;


	FILE *file;
	file = fopen("largeData.txt", "r");
	if (file == NULL){
		printf("File is not available \n");
	}
	else{
		while ((ch = fgetc(file)) != EOF){
			data[i] = ch;
			i++;
		}
	}


	int count;
	char pat[100] = "Angina  n. (in full angina pectoris) chest pain brought on by exertion, caused by an inadequate bl";
	int pat_s = strlen(pat);
	
	char *dev_data;
	char *dev_pat;
	int *dev_count;

	cudaMalloc((void**)&dev_data, size*sizeof(char));
	cudaMalloc((void**)&dev_pat, pat_s*sizeof(char));
	cudaMalloc((void **)&dev_count, sizeof(int));

	cudaMemcpy(dev_data, data, size*sizeof(char), cudaMemcpyHostToDevice);
	cudaMemcpy(dev_pat, pat, pat_s*sizeof(char), cudaMemcpyHostToDevice);

        int threads_per_block = 150;
        int block_size = 100;
        int offset = (size/(block_size * threads_per_block)) + 1;


	search<<<block_size,threads_per_block>>>(dev_data, size, dev_pat, pat_s, offset, dev_count);


	cudaMemcpy(&count, dev_count, sizeof(int), cudaMemcpyDeviceToHost);
	printf("\nfrequency of \"%s\" in data: %d  ",pat, count);
	fclose(file);
	
	cudaFree(dev_data);
	cudaFree(dev_pat);
	cudaFree(dev_count);

	t = clock() - t;
	double time_taken = ((double)t)/CLOCKS_PER_SEC;
	printf("\nIt took %f seconds for parallel code to execute \n", time_taken);

	return 0;
}

