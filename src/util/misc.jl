applymany(fs, x) = map(xi->xi(x), fs)

"""
Transpose for nested list / tuples.  Useful for output of rand(::NTuple{RandVar})
  
```jldoctest
x = normal(0.0, 1.0)
y = normal(0.0, 1.0)
samples = rand((x, y), x == y)
x_, y_ = ntranspose(samples)
```
"""
ntranspose(xs) = [[x[i] for x in xs] for i = 1:length(xs[1])]