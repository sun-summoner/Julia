include("all.jl")

function try_move!(robot, side)
    if !isborder(robot, side)
        move!(robot, inverse(side))
        return true
    end
    return false
end
function double_distance!(robot, side)
    if isborder(robot, side)
        return
    end
    move!(robot, side)
    double_distance!(robot, side)
    try_move!(robot, inverse(side))
    return try_move!(robot, inverse(side))
    
end
r = Robot(animate = true, "22a.sit")
double_distance!(r, West)
sleep(100)