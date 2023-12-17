include("all.jl")
function mark_labirint!(robot)
    if !ismarker(robot)
        putmarker!(robot)
        for side in (Nord, West, Sud, Ost)
            move!(robot, side)
            mark_labirint!(robot)
            move!(robot, inverse(side))
        end
    end
end

r = Robot(animate=true, "29.sit")
mark_labirint!(r)
sleep(100)