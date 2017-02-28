library(digest)

hll <- setRefClass('hll',
      fields = list(p = 'numeric', m = 'numeric', alpha = 'numeric', M = 'numeric', bitArray = 'numeric')
    , methods = list(
          initialize = function() {
              .self$p <- 4
              .self$m <- 2 ^ .self$p
              .self$alpha <- 0.673
              .self$M <- rep(0, .self$m)
              .self$bitArray <- 2 ^ c(0 : (32 - .self$p))
          }
        , add = function(value) { 
            x <- as.numeric(paste('0x', digest(value, algo=c('murmur32')), sep=''))

            j <- x %% .self$m   # equivalent to getting p-1 LSB bits
            w <- x / .self$m    # equivalent to bitwise right shift of p bits

            a <- which(.self$bitArray <= w)
            idx <- a[length(a)]

            rho <- length(.self$bitArray) - idx
            
            if (rho == 0)
                stop("Overflow error")
            
            j <- j + 1 # since R uses indexing starting from 1 we need to offset j
            .self$M[j] = max(.self$M[j], rho)
        }
        , len = function() {
            .self$alpha * (.self$m ^ 2) / sum(2 ^ (-1 * .self$M))
        }
    )
)