function summa(array, s=0) 
    if length(array) == 0
        return s
    end
    return summa(@view(array[1:end-1]), s + array[end])
end
print(summa(Vector{Int64}([1, 3, 5])))