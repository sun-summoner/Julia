using HorizonSideRobots
HSR = HorizonSideRobots

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


function HSR.move!(robot, sides)
    for s in sides
        move!(robot, s)
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


function HSR.isborder(robot, side::Tuple{HorizonSide, HorizonSide})
    return isborder(robot, side[1]) || isborder(robot, side[2])
end


function inverse(side)
    return HorizonSide((Int(side) + 2) % 4)
end

function inverse(s::Tuple{HorizonSide, HorizonSide})
    return map(inverse, s)
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
            count = markline!(robot, (side1, side2))
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


function go_along_with_check!(robot, side, side_of_check)
    while !isborder(robot, side)
            if isborder(robot, side_of_check)
                return true
            end
            move!(robot, side)
    end
    return false
end

function mark_boarder!(robot, side_check, side_go)
    while isborder(robot, side_check)
        putmarker!(robot)
        move!(robot, side_go)
    end
end


function perimetr_of_frames!(robot)
    num_west_steps, num_sud_steps = go_along!(robot, West), go_along!(robot, Sud)
    num_west_steps += go_along!(robot, West)
    perimetr!(robot)

    i = 3
    side = HorizonSide((i + 1) % 4)
    while !go_along_with_check!(robot, HorizonSide(i), side)
        i = (i + 2) % 4 
        move!(robot, side)
    end

    move!(robot, HorizonSide((i + 2) % 4))
    for side in (HorizonSide(i), HorizonSide((i + 1) % 4), HorizonSide((i + 2) % 4), HorizonSide((i + 3) % 4))
        side_go, side_check = side, HorizonSide((Int(side) + 1) % 4)
        putmarker!(robot)
        move!(robot, side_go)
        mark_boarder!(robot, side_check, side_go)
    end

    go_along!(robot, West)
    go_along!(robot, Sud)
    go_steps!(robot, Nord, num_sud_steps)
    go_steps!(robot, Ost, num_west_steps)
    
    
end

p = Robot(animate=true, "untitled.sit")

sleep(100)
