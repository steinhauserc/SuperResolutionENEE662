
Notes from Carl

- Can switch to using solveQuadprog just about everywhere for better runtime
- solveCVX will still be used for runtime comparison
- Moved all functions into "functions" folder to help make it easier to keep 
  track of scripts
- Running setupPaths.m script will add all subdirectories to the path so 
  those functions will be accessible
- I noticed in averageimage that the offsets were being randomly generated 
  again instead of using the input offsets, so I commented out those lines
- I think that formulateProblemV2 works fairly well. I'll still test it a 
  bit more but I think it should be okay to switch to using that one. Let 
  me know if you find any problems

