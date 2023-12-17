include("all.jl")

function one_side!(robot, side, num)
    if isborder(robot, side)
        return false
    end
    if num == 0
        return true
    end
    move!(robot, side)
    one_side!(robot, side, num - 1)
end

function recursive_shuttle!(robot, side, num)
    if !one_side!(robot, side, num)
        if mod(num, 2) == 0
            one_side!(robot, inverse(side), div(num + 1, 2))
        elseif mod(num, 2) == 1
            one_side!(robot, inverse(side), div(num + 1, 2) * 2)
        end
        return
    end
    recursive_shuttle!(robot, inverse(side), num + 1)
end
r = Robot(animate=true, "22b.sit")
recursive_shuttle!(r, West, 1)
sleep(100)