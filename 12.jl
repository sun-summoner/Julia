include("all.jl")


mutable struct CountBordersWithHolesRobot <: AbstractRobot
    robot::Robot
    num_markers::Int64
end

get_base_robot(robot::CountBordersWithHolesRobot) = robot.robot

function go_along!(robot::CountBordersWithHolesRobot, side)
    state = 0
    while !isborder(robot, side)
        move!(robot, side)
        if state == 0
            if isborder(robot, Nord)
                state = 2
                robot.num_markers += 1
            end
        elseif state == 1
            if isborder(robot, Nord)
                state = 2
            else
                state = 0
            end
        elseif state == 2
            if !isborder(robot, Nord)
                state = 1
            end
        end
    end
end

r = Robot(animate=true, "12.sit")
q = CountBordersWithHolesRobot(r, 0)
num_of_borders!(q)
sleep(100)