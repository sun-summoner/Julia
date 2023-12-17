using HorizonSideRobots
HSR = HorizonSideRobots

function inverse(side)
    return HorizonSide((Int(side) + 2) % 4)
end
left(side::HorizonSide) = HorizonSide(mod(Int(side) + 1, 4))
right(side::HorizonSide) = HorizonSide(mod(Int(side) - 1, 4))
function HSR.move!(robot, side::Tuple)
    for s in side
        move!(robot, s)
    end
end
abstract type AbstractRobot end
abstract type AbstractCoordsRobot end
get_base_robot(robot::Robot) = robot


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

struct PutmarkersRobot{TypeRobot} <: AbstractRobot
    robot::TypeRobot
end
get_base_robot(robot::PutmarkersRobot) = robot.robot
get_base_robot(robot::Robot) = robot

function HSR.move!(robot::PutmarkersRobot, side)
    move!(get_base_robot(robot), side)
    putmarker!(robot)
end

function try_move!(robot::PutmarkersRobot, side::HorizonSide)
    t = try_move!(get_base_robot(robot), side)
    t[1] && putmarker!(robot)
    return t
end

function try_move!(robot::PutmarkersRobot, (side1, side2)::Tuple)
    if isborder(get_base_robot(robot), side1) && isborder(get_base_robot(robot), side2)
        return false, 0
    end
    robot = CoordsRobot(get_base_robot(robot))
    if !isborder(get_base_robot(robot), side1) && !isborder(get_base_robot(robot), side2)
        move!(robot, side1)
        if !isborder(get_base_robot(robot), side2)
            move!(robot, side2)
            putmarker!(robot)
            return true, 1
        end
    end

    x, y = get(robot.coordinates)
    flag = (side1 == Nord && side2 == Ost) || (side1 == Sud && side2 == West)
    if isborder(get_base_robot(robot), side1)
        side_f, side_s = side1, side2
    else
        side_f, side_s = side2, side1
    end
    function check(robot, flag)
        x, y = get(robot.coordinates)
        if flag == 1
            return x == y
        end
        return x == -y
    end
    move!(robot, side_s)
    n = go_along!(() -> !isborder(robot, side_f) || check(robot, flag), robot, side_s) + 1

    if !check(robot, flag)
        t = try_move!(robot, side_f)

        if t[1]
            go_along!(() -> !isborder(robot, inverse(side_s)) || check(robot, flag), robot, side_f)

            if !check(robot, flag)
                move!(robot, inverse(side_s))
                go_along!(() -> !isborder(robot, inverse(side_f)) || check(robot, flag), robot, inverse(side_s))
            end
        else
            go_steps!(robot, inverse(side_s), n)
            return false, 0

        end
    end
    putmarker!(robot)
    return true, abs(x)
end

function try_move!(robot::Union{Robot,AbstractRobot}, side)
    ortogonal_side = left(side)
    back_side = inverse(ortogonal_side)
    n = 0
    if !isborder(robot, side)
        move!(robot, side)
        return true, 1, 0
    end
    while isborder(robot, side) && !isborder(robot, ortogonal_side)
        move!(get_base_robot(robot), ortogonal_side)
        n += 1
    end
    if isborder(robot, side)
        go_steps!(get_base_robot(robot), back_side, n)
        return false, 0, 0
    end
    move!(get_base_robot(robot), side)
    if n > 0 # продолжается обход
        k = go_along!(() -> !isborder(robot, back_side), get_base_robot(robot), side)
        go_steps!(get_base_robot(robot), back_side, n - 1)
        try_move!(robot, back_side)
    end
    return true, n, k
end

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

struct AllCoordsRobot{TypeRobot} <: AbstractRobot
    robot::TypeRobot
end

get_base_robot(robot::AllCoordsRobot) = robot.robot
function HorizonSideRobots.move!(robot::AllCoordsRobot, side)
    move!(robot.robot, side)
end

struct CoordsRobot <: AbstractRobot
    robot::Robot
    coordinates::Coordinates
    CoordsRobot(r) = new(r, Coordinates(0, 0))
end
function HorizonSideRobots.move!(robot::CoordsRobot, side)
    move!(get_base_robot(robot), side)
    move!(robot.coordinates, side)
end

get_base_robot(robot::CoordsRobot) = robot.robot

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

function go_along!(stop_condition::Function, robot::Union{Robot, AbstractRobot}, side)
    num_side_steps = 0
    while !stop_condition() && try_move!(robot, side)[1]
        num_side_steps += 1
    end
    return num_side_steps
end

function go_steps!(robot::Union{Robot,AbstractRobot}, side, steps)
    count = 1
    while count <= steps
        t = try_move!(robot, side)
        if !t[1]
            return count - 1
        else
            count += t[3] + 1
        end
    end
    return count
end

function go_steps!(stop_condition, robot, side, steps)
    for count in 1:steps
        if stop_condition() || !try_move!(robot, side)[1]
            return count - 1
        end
    end
    return steps
end

function go_along!(robot::Union{Robot,AbstractRobot}, (side1, side2)::Tuple)
    num_side_steps = 0
    v = try_move!(robot, (side1, side2))
    num_side_steps += v[2]
    while v[1]
        v = try_move!(robot, (side1, side2))
        num_side_steps += v[2]
    end
    return num_side_steps
end

function go_along!(robot::Union{Robot,AbstractRobot}, side)
    num_side_steps = 0
    while try_move!(robot, side)[1]
        num_side_steps += 1
    end
    return num_side_steps
end

function straight_cross!(robot::AbstractRobot)
    for side in (Nord, Sud, West, Ost)
        count = go_along!(robot, side)
        go_steps!(robot, inverse(side), count)
    end
    putmarker!(robot)
end

function snake!(stop_condition::Function, robot, (move_side, next_row_side))

    go_along!(stop_condition, robot, move_side)
    while !stop_condition() && try_move!(robot, next_row_side)[1]
        move_side = inverse(move_side)
        go_along!(stop_condition, robot, move_side)
    end
    return move_side
end
snake!(robot, (move_side, next_row_side)) = snake!(() -> false, robot, (move_side, next_row_side))

function shuttle!(stop_condition::Function, robot, side)
    n = 0 # число шагов от начального положения
    while !stop_condition() #!isborder(robot, Nord)
        n += 1
        go_steps!(robot, side, n)
        side = inverse(side)
    end
    return n, side
end

function find_a_hole!(robot, side)
    n, return_side = shuttle!(() -> !isborder(robot, side), robot, left(side))
    move!(robot, side)
    go_steps!(robot, return_side, (n + 1) // 2)
end

function spiral!(stop_condition, robot, side=Nord)
    n = 1
    while !stop_condition()
        go_steps!(() -> stop_condition(), robot, side, n)
        if stop_condition()
            continue
        end
        side = left(side)
        go_steps!(() -> stop_condition(), robot, side, n)
        if stop_condition()
            continue
        end
        side = left(side)
        n += 1
    end
end
function along!(robot, side)
    if !isborder(robot, side)
        move!(robot, side)
        along!(robot, side)
    end
end
function double_distance!(robot, side)
    if isborder(robot, side)
        return
    end
    move!(robot, side)
    double_distance!(robot, side)
    move!(robot, inverse(side))
    move!(robot, inverse(side))
end

function symmetric_move!(robot, side)
    if isborder(robot, side)
        go_along!(robot, inverse(side))
    else
        move!(robot, side)
        symmetric_move!(robot, side)
        move!(robot, side)
    end
end

function perimetr!(robot::PutmarkersRobot)
    num_west_steps, num_sud_steps = go_along!(get_base_robot(robot), West), go_along!(robot.robot, Sud)
    for side in (Nord, Ost, Sud, West)
        go_along!(robot, side)
    end
    go_steps!(get_base_robot(robot), Nord, num_sud_steps)
    go_steps!(get_base_robot(robot), Ost, num_west_steps)
end

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
            labirint_traversal!(actions, robot)
            move!(get_base_robot(robot), inverse(side))
        end
    end
end