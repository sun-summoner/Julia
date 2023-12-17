include("all.jl")

function along!(robot, side)
    if !isborder(robot, side)
        move!(robot, side)
        along!(robot, side)
    end
end
r = Robot(animate=true, "19.sit")
along!(r, West)
sleep(100)