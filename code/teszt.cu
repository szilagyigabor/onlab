    #include <iostream>
    #include <math.h>
     
    // CUDA kernel to add elements of two arrays
    __global__
    void add(int n, float *x, float *y)
    {
      int index = blockIdx.x * blockDim.x + threadIdx.x;
      int stride = blockDim.x * gridDim.x;
      for (int i = index; i < n; i += stride)
        y[i] = x[i] + y[i];
    }
     
    int main(void)
    {
      int N = 1<<25;
      float *x, *y;
     
      cudaEvent_t start, stop;
      cudaEventCreate(&start);
      cudaEventCreate(&stop);

      // Allocate Unified Memory -- accessible from CPU or GPU
      cudaMallocManaged(&x, N*sizeof(float));
      cudaMallocManaged(&y, N*sizeof(float));
     
      // initialize x and y arrays on the host
      for (int i = 0; i < N; i++) {
        x[i] = 1.0f;
        y[i] = 2.0f;
      }
     
      // Launch kernel on 1M elements on the GPU
      int blockSize = 32;
      int numBlocks = (N + blockSize - 1) / blockSize;
      
      cudaEventRecord(start);
      add<<<numBlocks, blockSize>>>(N, x, y);
      cudaEventRecord(stop);
     
      // Wait for GPU to finish before accessing on host
      cudaDeviceSynchronize();
      cudaEventSynchronize(stop);

      float milliseconds = 0;
      cudaEventElapsedTime(&milliseconds, start, stop);

      // Check for errors (all values should be 3.0f)
      float maxError = 0.0f;
      for (int i = 0; i < N; i++)
        maxError = fmax(maxError, fabs(y[i]-3.0f));
      std::cout << "Max error: " << maxError << std::endl;
      std::cout << "Eltelt idő: " << milliseconds << " ms" << std::endl;
     
      // Free memory
      cudaFree(x);
      cudaFree(y);
     
      return 0;
    }
