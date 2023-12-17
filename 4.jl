using HorizonSideRobots
HSR = HorizonSideRobots
include("all.jl")

function diagonal_cross!(robot::PutmarkersRobot)
    for side1 in (Nord, Sud)
        for side2 in (West, Ost)
            count = go_along!(robot, (side1, side2))
            go_steps!(get_base_robot(robot), inverse(side1), count[1])
            go_steps!(get_base_robot(robot), inverse(side2), count[2])
        end
    end
    putmarker!(robot)
end
r = Robot(animate=true, "4.sit")
q = PutmarkersRobot{Robot}(r)
diagonal_cross!(q)
sleep(100)