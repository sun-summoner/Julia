include("all.jl")

struct InfinityBorderRobot <:AbstractRobot
    robot::Robot
end
get_base_robot(robot::InfinityBorderRobot) = robot.robot
function try_move!(robot::InfinityBorderRobot, side)
    if !isborder(get_base_robot(robot), side)
        move!(get_base_robot(robot), side)
        return true, 1
    end
    find_a_hole!(get_base_robot(robot), side)
    return true, 1
end

r = Robot(animate=true, "18b.sit")
q = InfinityBorderRobot(r)
spiral!(() -> ismarker(q.robot), q)
sleep(100)