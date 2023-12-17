include("all.jl")
mutable struct Coordinates
    x::Int
    y::Int
end

function HorizonSideRobots.move!(coord::Coordinates,
    side::HorizonSide)
    if side == Nord
        coord.y += 1
    elseif side == Sud
        coord.y -= 1
    elseif side == Ost
        coord.x += 1
    elseif side == West
        coord.x -= 1
    end
end
get(coord::Coordinates) = (coord.x, coord.y)


struct ChessRobotN <: AbstractRobot
    robot::Robot
    coordinates::Coordinates
    N::Int
    mode::Bool
    ChessRobotN(r, N, mode) = new(r, Coordinates(0, 0), N, mode)
end

get_base_robot(robot::ChessRobotN) = robot.robot

function check_chess(robot::ChessRobotN, x, y)
    if robot.mode && (isodd(x) && isodd(y) || iseven(x) && iseven(y))
        putmarker!(robot)
    elseif !robot.mode && (isodd(x) && iseven(y) || iseven(x) && isodd(y))
        putmarker!(robot)
    end
end
function HorizonSideRobots.move!(robot::ChessRobotN, side)
    move!(get_base_robot(robot), side)
    move!(robot.coordinates, side)
    x, y = get(robot.coordinates)
    x = div(x, robot.N)
    y = div(y, robot.N)
    check_chess(robot, x, y)
end
r = Robot(animate=true)
q = ChessRobotN(r, 3, true)
putmarker!(q)
snake!(q, (Ost, Nord))
sleep(100)