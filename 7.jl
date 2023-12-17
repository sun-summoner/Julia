include("all.jl")

function shuttle!(stop_condition::Function, robot, side)
    n = 0 # число шагов от начального положения
    while !stop_condition() #!isborder(robot, Nord)
        n += 1
        go_steps!(robot, side, n)
        side = inverse(side)
    end
    return n, side
end

function find_a_hole!(robot, side)
    n, return_side = shuttle!(() -> !isborder(robot, side), robot, left(side))
    move!(robot, side)
    go_steps!(robot, return_side, (n + 1) // 2)
end

r = Robot(animate=true, "7.sit")
find_a_hole!(r, Nord)
sleep(100)