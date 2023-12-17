include("all.jl")



function marked_coords!(robot)
    for side in (Nord, West, Sud, Ost)
        num_steps = go_along!(robot, side)
        putmarker!(robot)
        go_steps!(robot, inverse(side), num_steps)
    end
end

r = Robot(animate=true, "6b.sit")
marked_coords!(r)
sleep(100)