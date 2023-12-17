include("all.jl")

function half_distance!(robot, side)
    if !isborder(robot, side)
        move!(robot, side)
        action!(robot, side)
        move!(robot, inverse(side))
    end
end
162
function action!(robot,side)
    if !isborder(robot, side)
        move!(robot, side)
        half_distance!(robot, side)
    end
end

r = Robot(animate=true, "24.sit")
half_distance!(r, West)
sleep(100)