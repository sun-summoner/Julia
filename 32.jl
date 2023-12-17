function show_typetree(type, level=0)
    println(" "^level, type)
    for t in subtypes(type)
        show_typetree(t, level + 4)
    end
end
show_typetree(Integer)
