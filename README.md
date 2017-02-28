# Introduction
An attempt to implement the Hyperloglog algorithm in R. Mainly for use as an educational tool - for myself. 

# Implementation
My implementation in R uses 16 buckets. The program was hardcoded with this because of R's inability to deal with 
high precision arithmetic operations, and the unavailability of bitwise operators. I also eschewed small and large range corrections 
suggested by the authors their original paper, and chose to verify the original paper's estimation of the errors instead.

## The hll object:
* p: The number of bits that acts as the basis for the rest of the attributes. 
* m: The number of registers/buckets = 2^p
* M: A register of size m 
* alpha: The bias correction constant
* bitArray: A convenience array that helps determine (rho) in the absence of bitwise operators 

## Some results observed:
1. For an empty set, we get an expected error. The error is expected to be approximately 0.7m.

```r
print(test$len())
[1] 10.768
```
2. For a set of 10 elements, which is still within small range corrections (5*m/2), the length is reported as 15.9. If we were to calculate the correction recommended (m * ln(m/V)), we would get approximately the correct length at 9.2 

```r
input <- sample(0:100, 10)
sapply(input, test$add)
print(test$len())
[1] 15.97455
print(log(test$m / length(which(test$M == 0))) * test$m)
[1] 9.205826
```

3. At 40 elements we expect the asymptic behaviour to kick in. The length reported by the algorithm was 33.27 which has a relative error 
of 0.17 which is less than the average error expected from the algorithm (+-1.04/m^0.5)

```r
input <- sample(0:100, 40)
sapply(input, test$add)
print(test$len())
[1] 33.27106
```

4. When adding 100 elements with duplicates, the algorithm predicts a length with a relative error of 0.106

```r
input <- sample(0:100, 100, replace=TRUE)
sapply(input, test$add)
predicted_l <- test$len()
actual_l <- length(unique(input))
err <- (actual_l - predicted_l)/actual_l
paste("Actual length:", actual_l, ", Predicted length:", predicted_l, ", Relative error:", err)
[1] "Actual length: 61 , Predicted length: 54.5188232385661, Relative error: 0.106248799367768"
```

5. When adding a 1,000,000 elements with duplicates, the algorithm predicts a length with a relative error -0.39

```r
input <- sample(0:1000000, 95000, replace=TRUE)
sapply(input, test$add)
predicted_l <- test$len()
actual_l <- length(unique(input))
err <- (actual_l - predicted_l)/actual_l
paste("Actual length:", actual_l, ", Predicted length:", predicted_l, ", Relative error:", err)
[1] "Actual length: 90619 , Predicted length: 126510.547540616, Relative error: -0.396070885141265"
```

6. As I tested with more elements, the performance degradation due to the cost of the hash function was quite apparent. 
When trying to add a 100 million elements, the add function did not return for over 15 minutes.

# References
- [HyperLogLog in Practice: Algorithmic Engineering of a State of The Art Cardinality Estimation Algorithm](https://stefanheule.com/papers/edbt13-hyperloglog.pdf)
- [Hyperloglog: The analysis of a near-optimal cardinality estimation algorithm](https://hal.inria.fr/hal-00406166/document)
- [pyhll](https://pypi.python.org/pypi/hyperloglog)
