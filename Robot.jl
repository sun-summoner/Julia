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

function go_steps!(robot, side, steps, f)
    func = f
    for _ in 1:steps
        if func(robot)
            return false
        end
        move!(robot, side)
    end
    return true
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


function find_border!(robot, side, side_of_check)
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
            if !isborder(robot, side_go)
                move!(robot, side_go)
            end
           
    end
end


function perimetr_of_frames!(robot)
    num_west_steps, num_sud_steps = go_along!(robot, West), go_along!(robot, Sud)
    num_west_steps += go_along!(robot, West)
    perimetr!(robot)

    i = Ost
    side = Nord
    while !find_border!(robot, i, side)
        i = inverse(i)
        move!(robot, side)
    end

    move!(robot, inverse(i))
    for side in (i, Nord, inverse(i), Sud)
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


function find_hole!(robot)
    side = Ost
    n = 0
    while isborder(robot, Nord)
        n += 1
        side = inverse(side)
        go_steps!(robot, side, n)
    end
    move!(robot, Nord)
    go_steps!(robot, inverse(side), (n + 1) // 2)

end

function find_point!(robot)
    i = 3
    while true
        if go_steps!(robot, Sud, 1, ismarker) && go_steps!(robot, West, div(i, 2), ismarker) &&
           go_steps!(robot, Nord, i - 1, ismarker) &&
           go_steps!(robot, Ost, i - 1, ismarker) &&
           go_steps!(robot, Sud, i - 1, ismarker) &&
           go_steps!(robot, West, div(i, 2), ismarker)
            i += 2
        else
            break
        end
    end
end


function perimetr_with_obstacles!(robot)
    num_steps = Int[]
    delta_w = delta_s = 1
    while delta_w + delta_s > 0
        delta_w = go_along!(robot, West)
        delta_s = go_along!(robot, Sud)
        push!(num_steps, delta_w)
        push!(num_steps, delta_s)
    end

    perimetr!(robot)
    i = length(num_steps)
    sides = (Nord, Ost)
    j = 0
    while i >= 1
        go_steps!(robot, sides[j+1], num_steps[i])
        j = (j + 1) % 2
        i -= 1
    end
end

function num_of_borders!(robot)
    num = 0
    num_west_steps = go_along!(robot, West)
    num_sud_steps = go_along!(robot, Sud)
    side = Ost
    while !isborder(robot, Nord)
        num += go_along_with_count_full!(robot, side)
        move!(robot, Nord)
        side = inverse(side)
    end
    num += go_along_with_count_full!(robot, side)

    go_along!(robot, West)
    go_along!(robot, Sud)
    go_steps!(r, Nord, num_sud_steps)
    go_steps!(r, West, num_west_steps)
    return num
end

function go_along_with_count_full!(robot, side)
    n = 0
    flag = false
    while !isborder(robot, side)
        move!(robot, side)
        if isborder(robot, Nord)
            flag = true
        end
        if flag == true && !isborder(robot, Nord)
            n += 1
            flag = false
        end
    end
    return n
end

function go_along_with_count_hole!(robot, side)
    n = 0
    state = 0
    while !isborder(robot, side)
        move!(robot, side)
        if state == 0
            if isborder(robot, Nord)
                state = 2
                n += 1
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
    return n
end
function mark_like_chess!(robot, side, state)
    while !isborder(robot, side)
        move!(robot, side)
        state += 1
        (state % 2 == 1) && putmarker!(robot)
    end
    return state
end

function chess_board!(robot)
    state = 1
    putmarker!(robot)
    num_west_steps = 0
    while !isborder(robot, West)
        move!(robot, West)
        state += 1
        (state % 2 == 1) && putmarker!(robot)
        num_west_steps += 1
    end
    state = mark_like_chess!(robot, Ost, state)
    side = West
    for sides in (Nord, Sud)
        num_steps = 0
        while !isborder(robot, sides)
            move!(robot, sides)
            num_steps += 1
            state += 1
            (state % 2 == 1) && putmarker!(robot)
            state = mark_like_chess!(robot, side, state)
            side = inverse(side)
        end
        go_steps!(robot, inverse(sides), num_steps)
        state += num_steps
    end

    go_along!(robot, West)
    go_steps!(robot, Ost, num_west_steps)

end

p = Robot(animate=true, "untitled.sit")
r = Robot(animate=true)

sleep(100)

