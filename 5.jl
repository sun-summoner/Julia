using HorizonSideRobots
HSR = HorizonSideRobots
include("all.jl")

function  outside_perimetr!(robot::PutmarkersRobot, i)
    for side in (i, Nord, inverse(i), Sud)
        side_check = HorizonSide((Int(side) + 1) % 4)
        move!(robot, side)
        go_along!(() -> !isborder(robot, side_check), robot, side)
    end
end
function perimetr_of_frames!(robot::PutmarkersRobot)
    perimetr!(robot)
    num_west_steps, num_sud_steps = go_along!(get_base_robot(robot), West), go_along!(get_base_robot(robot), Sud)
    num_west_steps += go_along!(get_base_robot(robot), West)
    
    side = snake!(() -> isborder(get_base_robot(robot), Nord), get_base_robot(robot), (Ost, Nord))
    move!(get_base_robot(robot), inverse(side))

    outside_perimetr!(robot, side)

    go_along!(get_base_robot(robot), West)
    go_along!(get_base_robot(robot), Sud)
    go_steps!(get_base_robot(robot), Nord, num_sud_steps)
    go_steps!(get_base_robot(robot), Ost, num_west_steps)

end
r = Robot(animate=true, "5.sit")
q = PutmarkersRobot{Robot}(r)
perimetr_of_frames!(q)
sleep(100)