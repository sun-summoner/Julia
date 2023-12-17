using HorizonSideRobots
HSR = HorizonSideRobots
include("all.jl")

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

function diagonal_cross!(robot::PutmarkersRobot)
    for side1 in (Nord, Sud)
        for side2 in (West, Ost)
            count = go_along!(robot, (side1, side2))
            go_steps!(get_base_robot(robot), inverse(side1), count)
            go_steps!(get_base_robot(robot), inverse(side2), count)
        end
    end
    putmarker!(robot)
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

r = Robot(animate=true, "15.sit")
q = PutmarkersRobot{Robot}(r)
diagonal_cross!(q)
sleep(100)