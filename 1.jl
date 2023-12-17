using HorizonSideRobots
HSR = HorizonSideRobots

function inverse(side)
    return HorizonSide((Int(side) + 2) % 4)
end
left(side::HorizonSide) = HorizonSide(mod(Int(side) + 1, 4))
right(side::HorizonSide) = HorizonSide(mod(Int(side) - 1, 4))

abstract type AbstractRobot end

get_base_robot(robot::Robot) = robot


HSR.move!(robot::AbstractRobot, side) =
    move!(get_base_robot(robot), side)
HSR.isborder(robot::AbstractRobot, side) =
    isborder(get_base_robot(robot), side)
HSR.putmarker!(robot::AbstractRobot) =
    putmarker!(get_base_robot(robot))
HSR.ismarker(robot::AbstractRobot) =
    ismarker(get_base_robot(robot))
HSR.temperature(robot::AbstractRobot) =
    temperature(get_base_robot(robot))

struct PutmarkersRobot{TypeRobot} <: AbstractRobot
    robot::TypeRobot
end
get_base_robot(robot::PutmarkersRobot) = robot.robot


function HSR.move!(robot::PutmarkersRobot, side)
    move!(robot.robot, side)
    putmarker!(robot)
end
"""
function try_move!(robot, side)
    if !isborder(robot, side)
        move!(robot, side)
        return true, 1
    end
    return false, 0
end
"""
function try_move!(robot::PutmarkersRobot, side)
    t = try_move!(robot.robot, side)
    t[1] && putmarker!(robot)
    return t
end

function try_move!(robot::Union{Robot, AbstractRobot}, side)
    ortogonal_side = left(side)
    back_side = inverse(ortogonal_side)
    n = 0
    if !isborder(robot, side)
        move!(robot, side)
        return true, 1
    end
    while isborder(robot, side) && !isborder(robot, ortogonal_side)
        move!(robot, ortogonal_side)
        n += 1
    end
    if isborder(robot, side)
        go_steps!(robot, back_side, n)
        return false, 0
    end
    move!(robot, side)
    if n > 0 # продолжается обход
        go_along!(() -> !isborder(robot, back_side), robot, side)
        go_steps!(robot, back_side, n-1)
        try_move!(robot, back_side)
    end
    return true, n
end

function go_along!(stop_condition, robot::AbstractRobot, side)
    num_side_steps = 0
    while !stop_condition() && try_move!(robot, side)[1]
        num_side_steps += 1
    end
    return num_side_steps
end

function go_steps!(robot::Union{Robot, AbstractRobot}, side, steps)
    for count in 1:steps
        if !try_move!(robot, side)[1]
            return count - 1
        end
    end
    return steps
end

function go_along!(robot::Union{Robot,AbstractRobot}, side)
    num_side_steps = 0
    while try_move!(robot, side)[1] 
        num_side_steps += 1
    end
    return num_side_steps
end

function straight_cross!(robot::AbstractRobot)
    for side in (Nord, Sud, West, Ost)
        count = go_along!(robot, side)
        go_steps!(robot, inverse(side), count)
    end
    putmarker!(robot)
end

r = Robot(animate=true, "1.sit")
q = PutmarkersRobot{Robot}(r)
straight_cross!(q)

sleep(100)