using HorizonSideRobots
HSR = HorizonSideRobots
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
    elseif side==West
        coord.x -= 1
    end
end
get(coord::Coordinates) = (coord.x, coord.y)

abstract type AbstractRobot end


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

abstract type AbstractCoordsRobot <: AbstractRobot end
struct CoordsRobot <: AbstractCoordsRobot
    robot::Robot
    x::Int
    y::Int
end
get_base_robot(robot::CoordsRobot) = robot.robot
get_coords(robot::CoordsRobot) = (robot.x, robot.y)
set_coords(robot::CoordsRobot, x, y) =
    (robot.x = x; robot.y = y; nothing)

mutable struct CountmarkersRobot <: AbstractRobot
    robot::Robot
    num_markers::Int64
end
 
get_base_robot(robot::CountmarkersRobot) = robot.robot

function HSR.move!(robot::CountmarkersRobot, side) 
    move!(robot.robot, side)
    if ismarker(robot)
        robot.num_markers += 1
    end
    nothing
end


function HSR.move!(robot::AbstractCoordsRobot, side::HorizonSide)
    move!(get_base_robot(robot))
    x, y = get_coords(robot)
    if side == Nord
        set_coords(robot, x, y + 1)
    elseif side == Sud
        set_coords(robot, x, y - 1)
    elseif side == Ost
        set_coords(robot, x + 1, y)
    elseif side==West
        set_coords(robot, x - 1, y)
    end
end

struct PutmarkersRobot <: AbstractRobot
    robot::Robot
end
get_base_robot(robot::PutmarkersRobot) = robot.robot
get_base_robot(robot::Robot) = robot

function HSR.move!(robot::PutmarkersRobot, side)
    invoke(move!, (AbstractRobot, Any), robot, side)
    putmarker!(robot)
end


struct ChessRobotN <: AbstractRobot
    robot::Robot
    coordinates::Coordinates
    N::Int
    ChessRobotN(r, n) = new(r, Coordinates(0, 0), N)
end

get_base_robot(robot::ChessRobotN) = robot.robot

function HorizonSideRobots.move!(robot::ChessRobotN, side)
    move!(robot.robot, side)
    move!(robot.coordinates, side)
    x, y = get(robot.coordinates)
    x = x // N
    y = y // N
    if isodd(x) && isodd(y) || iseven(x) && iseven(y)
        putmarker!(robot)
    end
end

left(side::HorizonSide) = HorizonSide(mod(Int(side) + 1, 4))
right(side::HorizonSide) = HorizonSide(mod(Int(side) - 1, 4))

function go_steps!(stop_condition, robot, side, steps)
    for count in 1:steps
        if stop_condition() || !try_move!(robot, side)[1]
            return count - 1
        end
    end
    return steps
end
function go_steps!(robot, side, steps)
    for count in 1:steps
        if !try_move!(robot, side)[1]
            return count - 1
        end
    end
    return steps
end

function go_along!(robot, side)
    num_side_steps = 0
    while try_move!(robot, side)[1] #try_move!(robot, side)
        num_side_steps += 1
    end
    return num_side_steps
end
function go_along!(stop_condition, robot, side)
    num_side_steps = 0
    while !stop_condition() && try_move!(robot, side)[1]
        num_side_steps += 1
    end
    return num_side_steps
end

function try_move!(robot::AbstractRobot, side)
    ortogonal_side = left(side)
    back_side = inverse(ortogonal_side)
    n = 0
    while isborder(robot, side) && !isborder(robot, ortogonal_side)
        move!(robot, ortogonal_side)
        n += 1
    end
    if !isborder(robot, side)
        move!(robot, side)
        return true, 1
    end
    if isborder(robot, side)
        go_steps!(robot, back_side, n)
        return false, 0
    end
    move!(robot, side)
    if n > 0 # продолжается обход
        go_along!(() -> !isborder(robot, back_side), get_baserobot(robot), side)
        go_steps!(robot, back_side, n)
    end
    return true, n
end

function inverse(side)
    return HorizonSide((Int(side) + 2) % 4)
end

function snake!(stop_condition::Function, robot, (move_side, next_row_side))
    go_along!(stop_condition, robot, move_side)
    while !stop_condition(move_side) && try_move!(robot, next_row_side)
        move_side = inverse(move_side)
        go_along!(stop_condition, robot, move_side)
    end
end
snake!(robot,(move_side, next_row_side)::NTuple{2,HorizonSide}=(Ost, Nord)) = snake!(() -> false, robot, (side1, side2))


function mark_like_chess!(robot, side, state)
    num_steps = 0
    while try_move!(robot, side)[1]
        state += 1
        (state % 2 == 1) && putmarker!(robot)
        num_steps += 1
    end
    return state, num_steps
end


function chess_board!(robot)
    state = 1
    putmarker!(robot)
    state, num_west_steps = mark_like_chess!(robot, West, state)
    state, num_sud_steps = mark_like_chess!(robot, Nord, state)

    snake!(robot, (Ost, Nord), state)

    go_along!(robot, West)
    go_along!(robot, Sud)
    go_steps!(robot, Ost, num_west_steps)
    go_steps!(robot, Nord, num_sud_steps)

end




p = Robot(animate=true, "untitled.sit")
robot = p
spiral!(() -> ismarker(robot), p)
sleep(100)
