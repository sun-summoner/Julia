include("all.jl")

mutable struct CountBordersRobot <: AbstractRobot
    robot::Robot
    num_markers::Int64
end

get_base_robot(robot::CountBordersRobot) = robot.robot

function go_along!(robot::CountBordersRobot, side)
    flag = false
    t = try_move!(robot, side)
    while t[1]
        if t[2] == 1
            robot.num_markers += 1
        end
        if isborder(robot, Nord)
            flag = true
        end
        if flag == true && !isborder(robot, Nord)
            robot.num_markers += 1
            flag = false
        end
        t = try_move!(robot, side)
    end
end


function num_of_borders!(robot)
    num_west_steps = go_along!(get_base_robot(robot), West)
    num_sud_steps = go_along!(get_base_robot(robot), Sud)
    snake!(robot, (Ost, Nord))


    go_along!(get_base_robot(robot), West)
    go_along!(get_base_robot(robot), Sud)

    go_steps!(get_base_robot(robot), Nord, num_sud_steps)
    go_steps!(get_base_robot(robot), Ost, num_west_steps)

    return robot.num_markers
end

r = Robot(animate=true, "11.sit")
q = CountBordersRobot(r, 0)
num_of_borders!(q)
sleep(100)
