function fib(n::Integer)
    f_prev = f_next = 1
    while n > 0
        f_next, f_prev = f_next + f_prev, f_next
        n -= 1
    end
    return f_prev
end

function recursion_fib(n::Integer)
    if n == 0 || n == 1
        return 1
    end
    return recursion_fib(n - 2) + recursion_fib(n - 1)
end

function memoize_fibonacci(n)
    known = Dict(0 => 0, 1 => 1)
    function fibonacci(n)
        if n ∈ keys(known)
            return known[n]
        end
        res = fibonacci(n - 1) + fibonacci(n - 2)
        known[n] = res
        res
    end
    return fibonacci(n)
end
print(memoize_fibonacci(100))