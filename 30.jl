include("all.jl")


struct LabirintRobot <: AbstractRobot
    robot::AllCoordsRobot
    passed_coords::Set
    LabirintRobot(robot) = new(robot, Set())
end

get_base_robot(robot::LabirintRobot) = get_base_robot(robot.robot)
function labirint_traversal!(actions, robot::LabirintRobot)
    if get(get_base_robot(robot).coordinates) in robot.passed_coords
        return
    end
    push!(robot.passed_coords, get(get_base_robot(robot).coordinates))
    actions()
    for side ∈ (Nord, West, Sud, Ost)
        if !isborder(robot, side)
            move!(get_base_robot(robot), side)
            labirint_traversal!(robot)
            move!(get_base_robot(robot), inverse(side))
        end
    end
end
t = AllCoordsRobot(ChessRobotN(Robot(animate=true, "26.sit"), 1, true))
q = LabirintRobot(t)
putmarker!(q)
labirint_traversal!(()-> nothing, q)
sleep(100)