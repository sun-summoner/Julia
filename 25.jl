include("all.jl")

function chess_put_line!(robot, side)
    if !isborder(robot, side)
        putmarker!(robot)
        move!(robot, side)
        chess_line!(robot, side)
    else
        putmarker!(robot)
    end
end

function chess_line!(robot, side)
    if !isborder(robot, side)
        move!(robot, side)
        chess_put_line!(robot, side)
    end
end
r = Robot(animate=true, "25.sit")
chess_put_line!(r, West)
sleep(100)