include("all.jl")
function recursive_try_move!(robot, side)
    if !isborder(robot, side)
        move!(robot, side)
        return
    end
    move!(robot, right(side))
    recursive_try_move!(robot, side)
    move!(robot, left(side))
end
r = Robot(animate=true, "21.sit")
recursive_try_move!(r, West)
sleep(100)