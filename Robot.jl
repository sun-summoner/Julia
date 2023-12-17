using HorizonSideRobots
HSR = HorizonSideRobots

function markline!(robot, side)
    c = 0
    while try_move!(robot, side)
        c += 1
        putmarker!(robot)
    end
    return c
end
function markline!(robot, (side1, side2))
    c = 0
    while try_move!(robot, side1)[1] && try_move!(robot, side2)[1]
        c += 1
        putmarker!(robot)
    end
    return c
end

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

function HSR.move!(robot, side::Tuple)
    for s in side
        move!(robot, s)
    end
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
        go_steps!(robot,inverse(side), count)
    end
    putmarker!(robot)
end

    

function perimetr!(robot)
    num_west_steps, num_sud_steps = go_along!(robot, West), go_along!(robot, Sud)
    for side in (Nord, Ost, Sud, West)
        markline!(robot, side)
    end
    go_steps!(robot,Nord, num_sud_steps)
    go_steps!(robot,Ost, num_west_steps)
end

function diagonal_cross!(robot)
    for side1 in (Nord, Sud)
        for side2 in (West, Ost)
            count = markline!(robot, (side1, side2))
            go_steps!(robot,inverse(side1), count)
            go_steps!(robot,inverse(side2), count)
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
    go_steps!(robot,Ost, num_west_steps)
    go_steps!(robot,Nord, num_sud_steps)
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
    go_steps!(robot,Nord, num_sud_steps)
    go_steps!(robot,Ost, num_west_steps)
    
    
end

function shuttle!(stop_condition::Function, robot, side)
    n = 0 # число шагов от начального положения
    while !stop_condition() #isborder(robot, Nord)
        n += 1
        go_steps!(robot, side, n)
        side = inverse(side)
    end
    return n, side
end

function find_a_hole!(robot)
    n, side = shuttle!(() -> !isborder(robot, Nord), robot, Ost)
    move!(robot, Nord)
    go_steps!(robot, side, (n + 1) // 2)
end

function left(side)
    return HorizonSide((Int(side) + 1) % 4)
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
        go_steps!(robot,sides[j+1], num_steps[i])
        j = (j + 1) % 2
        i -= 1
    end
end

function snake!(stop_condition::Function, robot, (move_side,next_row_side))

    go_along!(stop_condition, robot, move_side)
    while !stop_condition(move_side) && try_move!(robot, next_row_side)
        move_side = inverse(move_side)
        go_along!(stop_condition, robot, move_side)
    end
end
snake!(robot, (move_side, next_row_side)::NTuple{2,HorizonSide}=(Ost, Nord)) = snake!(() -> false, robot, (side1, side2))

function snake!(action, robot, (move_side, next_row_side), t)
    t += action(robot, move_side, t)
    while try_move!(robot, next_row_side)[1]
        move_side = inverse(move_side)
        t += action(robot, move_side, t)
    end
end

function num_of_borders!(robot)
    num_west_steps = go_along!(robot, West)
    num_sud_steps = go_along!(robot, Sud)
    snake!(go_along_with_count_full!, (Ost, Nord), 0)

    
    go_along!(robot, West)
    go_along!(robot, Sud)
    
    go_steps!(robot,Nord, num_sud_steps)
    go_steps!(robot,Ost, num_west_steps)
    
    return num
end
function marked_coords!(robot)
    for side in (Nord, West, Sud, Ost)
        num_steps = go_along!(robot, side)
        putmarker!(robot)
        go_steps!(robot,inverse(side), num_steps)
    end
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
    (state % 2 == 1) && putmarker!(robot)
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
    state_new = mark_like_chess!(robot, West, state)
    num_west_steps = state_new - state
    state = mark_like_chess!(robot, Sud, state_new)
    num_sud_steps = state - state_new

    snake!(mark_like_chess!, robot, (Ost, Nord), state)

    go_along!(robot, West)
    go_along!(robot, Sud)
    go_steps!(robot, Ost, num_west_steps)
    go_steps!(robot, Nord, num_sud_steps)

end


function square!(robot, n)
    side = Nord
    height = n - 1
    for length in 1:n
        putmarker!(robot)
        height = go_steps_and_mark!(robot, side, height)
        if !isborder(robot, Ost) && length != n
            move!(robot, Ost)
        else
            if n % 2 == 1
                go_steps!(robot, Sud, height)
            end
            return length - 1, height
        end
        side = inverse(side)
    end

    if n % 2 == 1
        go_steps!(robot, Sud, count)
    end
    return n - 1, height
end

function mark_like_big_chess!(n, robot, side, state)
    length = height = n - 1
    while !isborder(robot, side)
        state += 1
        if state % 2 == 1
            length, height = square!(robot, n)
        else
            length = n - 1
            length = go_steps!(robot, side, length)
        end
        if side == Ost
            go_steps!(robot, side, 1)
        else
            go_steps!(robot, side, length + 1)
        end
    end
    if (state % 2 == 0 && side == Ost) || (state % 2 == 1 && side == West)
        go_steps!(robot, inverse(side), length)
    end
    go_steps!(robot, Nord, height)
    return state
   
end

function big_chess_board!(robot, n)
    num_west_steps = go_along!(robot, West)
    num_sud_steps = go_along!(robot, Sud)
    snake!((robot, move_side, t) -> mark_like_big_chess!(n, robot, move_side, t), robot, (Ost, Nord), 0)

    go_along!(robot, West)
    go_along!(robot, Sud)
    go_steps!(robot,Ost, num_west_steps)
    go_steps!(robot,Nord, num_sud_steps)

end
function go_steps_and_mark!(robot, side, steps)
    for num in 1:steps
        if !isborder(robot, side)
            move!(robot, side)
        else
            return num - 1
        end
        putmarker!(robot)
    end
    return steps
end

function go_along_with_count_full!(robot, side)
    n = 0
    flag = false
    while true
        t = try_move!(robot, side)
        if !t[1]
            break
        end
        if t[2] == 1
            n += 1
        end
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

function try_move!(robot, side)
    n = 0
    if side in (Nord, Sud)
        new_side = West
    else
        new_side = Sud
    end
    if isborder(robot, side)
        while isborder(robot, side)
            if !isborder(robot, new_side)
                move!(robot, new_side)
                n += 1
            else
                go_steps!(robot, inverse(new_side), n)
                return false, 0
            end
        end
        move!(robot, side)
        while isborder(robot, inverse(new_side))
            move!(robot, side)
        end
        go_steps!(robot, inverse(new_side), n)
    else
        move!(robot, side)
    end
    return true, n
end


p = Robot(animate=true, "untitled.sit")
big_chess_board!(p, 3)
#spiral!(robot -> ismarker(robot), p)
sleep(100)
