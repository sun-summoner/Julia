include("all.jl")

function symmetric_move!(robot, side)
    if isborder(robot, side)
        go_along!(robot, inverse(side))
    else
        move!(robot, side)
        symmetric_move!(robot, side)
        move!(robot, side)
    end
end
r = Robot(animate=true, "23.sit")
symmetric_move!(r, West)
sleep(100)