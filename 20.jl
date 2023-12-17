include("all.jl")
function put_marker_at_the_end!(robot, side)
    if isborder(robot, side)
        putmarker!(robot)
        return
    end
    move!(robot, side)
    put_marker_at_the_end!(robot, side)
    move!(robot, inverse(side))
end

r = Robot(animate=true, "20.sit")
put_marker_at_the_end!(r, Nord)
sleep(100)