# Matrix Multiply

## General approach

1. read and buffer Matrix A
2. read and transpose Matrix B and save it
3. process A rowwise with B



## Components

### Transpose matrix


    a1 a2 a3 a4        a1 b1
    b1 b2 b3 b4   ==>  a2 b2
                       a3 b3
                       a4 b4

How could we do this in a streaming fashion?

1. put the RxC matrix into a repeater
2. loop for c from 0..<C
    1. loop for r from 0..<R
        1. loop for c1 from 0..<R
	    1. read from repeater
	    2. if c1==c then send to output



### Pairwise multiply and sum:

Input: N a1 b1 ... an bn

Output:

a1*b1 + ... + an*bn

