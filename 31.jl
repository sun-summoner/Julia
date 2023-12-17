include("all.jl")
struct DiagonalCoordsRobot <: AbstractRobot
    robot::Robot
    coordinates::Coordinates
    DiagonalCoordsRobot(r) = new(r, Coordinates(0, 0))
end
get_base_robot(robot::DiagonalCoordsRobot) = robot.robot

function HorizonSideRobots.move!(robot::DiagonalCoordsRobot, side)
    move!(get_base_robot(robot), side)
    move!(robot.coordinates, side)
    function check(robot)
        x, y = get(robot.coordinates)
        return (x == -y) || (x == y)
    end
    check(robot)&&putmarker!(robot)
end
r = Robot(animate=true, "untitled.sit")
q = DiagonalCoordsRobot(r)
labirint_traversal!(()-> nothing, LabirintRobot(AllCoordsRobot(q)))
sleep(100)
