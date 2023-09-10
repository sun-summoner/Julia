using HorizonSideRobots


r = Robot(animate=true)
function markline!(robot, side)
    c = 0
    while !isborder(robot, side)
        c += 1
        move!(robot, side)
        putmarker!(robot)
    end
    return c
end
function go_steps!(robot, side, steps)
    for _ in 1:steps
        move!(robot, side)
    end
end

function go_along!(robot, side)
    num_side_steps = 0
    while !isborder(robot, side)
        move!(robot, side)
        num_side_steps += 1
    end
    return num_side_steps
end


function inverse(side)
    return HorizonSide((Int(side) + 2) % 4)
end


function mark_diagonal!(robot, side1, side2)
    c = 0
    while !(isborder(robot, side1) || isborder(robot, side2))
        c += 1
        move!(robot, side1)
        move!(robot, side2)
        putmarker!(robot)
    end
    return c
end


function straight_cross!(robot)
    for side in (Nord, Sud, West, Ost)
        count = markline!(robot, side)
        go_steps!(robot, inverse(side), count)
    end
    putmarker!(robot)
end

    

function perimetr!(robot)
    num_west_steps, num_sud_steps = go_along!(robot, West), go_along!(robot, Sud)
    for side in (Nord, Ost, Sud, West)
        markline!(robot, side)
    end
    go_steps!(robot, Nord, num_sud_steps)
    go_steps!(robot, Ost, num_west_steps)
end

function diagonal_cross!(robot)
    for side1 in (Nord, Sud)
        for side2 in (West, Ost)
            count = mark_diagonal!(robot, side1, side2)
            go_steps!(robot, inverse(side1), count)
            go_steps!(robot, inverse(side2), count)
        end
    end
    putmarker!(robot)
end


function whole_field!(robot)
    num_west_steps, num_sud_steps = go_along!(robot, West), go_along!(robot, Sud)
    side = Ost
    putmarker!(robot)
    markline!(robot, side)
    while !isborder(robot, Nord)
        move!(robot, Nord)
        putmarker!(robot)
        side = inverse(side)
        markline!(robot, side)
    end
    go_along!(robot, West)
    go_along!(robot, Sud)
    go_steps!(robot, Ost, num_west_steps)
    go_steps!(robot, Nord, num_sud_steps)
end


function go_along_with_check!(robot, side)
    flag = false
    while !isborder(robot, side)
            flag = isborder(robot, Nord)
            if flag
                return flag
            end
            move!(robot, side)
    end
    return flag
end

function mark_boarder!(robot, side_check, side_go)
    while isborder(robot, side_check)
        putmarker!(robot)
        move!(robot, side_go)
    end
end


function perimetr_of_frames!(robot)
    num_west_steps, num_sud_steps = go_along!(robot, West), go_along!(robot, Sud)
    
    perimetr!(robot)
    
    while !go_along_with_check!(robot, Ost)
        go_along!(robot, West)
        move!(robot, Nord)
    end
    move!(robot, West)
    for side in (Ost,Nord,West,Sud)
        side_go, side_check = side, HorizonSide((Int(side) + 1) % 4)
        putmarker!(robot)
        move!(robot, side_go)
        mark_boarder!(robot, side_check, side_go)
    end

    go_along!(robot, West), go_along!(robot, Sud)
    go_steps!(robot, Nord, num_sud_steps)
    go_steps!(robot, Ost, num_west_steps)
    
    
end

p = Robot(animate=true, "untitled.sit")

sleep(100)
