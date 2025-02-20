# 4x4 Systolic Array Matrix Multiplication
The implementation of a weight-stationary systolic array ranges from a size of 4x4 (scalable) up to 256x256.

# MMU (Matrix Multiplication Unit)
The MMU module represents the top-level structure for matrix multiplication using a systolic array. It processes several inputs through multiple MAC (Multiply-Accumulate) units organized in a 2D array, resulting in an output accumulator.

# MAC (Multiply-Accumulate)
Each MAC module symbolizes a single multiply-accumulate unit. It takes input data, multiplies it with weights, accumulates the results, and produces output data and accumulation.

# Overall Design
The MMU module orchestrates the interaction between multiple MAC modules, arranging them in a systolic array for matrix multiplication. The MAC module manages single multiply-accumulate operations, including weight loading and accumulator reset. This design aims at efficient matrix multiplication in a systolic array configuration. The correct flow of data and weights is crucial for system integrity, as verified through extensive testing and verification procedures.

# Performance Analysis
DC synthesis using the ASAP7 PDK provided detailed reports on area, timing, power, synthesis, and possible violations. Post-synthesis gate-level simulation results were also validated, offering deeper insights into the design's performance and behavior. 
