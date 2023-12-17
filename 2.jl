using HorizonSideRobots
HSR = HorizonSideRobots
include("all.jl")

function perimetr!(robot::PutmarkersRobot)
    num_west_steps, num_sud_steps = go_along!(get_base_robot(robot), West), go_along!(robot.robot, Sud)
    for side in (Nord, Ost, Sud, West)
        go_along!(robot, side)
    end
    go_steps!(get_base_robot(robot), Nord, num_sud_steps)
    go_steps!(get_base_robot(robot), Ost, num_west_steps)
end

r = Robot(animate=true, "2.sit")
q = PutmarkersRobot{Robot}(r)
perimetr!(q)
sleep(100)