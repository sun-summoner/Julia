include("all.jl")


function max_temperature!(robot)
    max_tmpr = temperature(robot)
    labirint_traversal!(robot) do
        current = temperature(robot)
        if current > max_tmpr
            max_tmpr = current
        end
    end
    return max_tmpr
end

function find_max_temperature!(robot, temp)
    p = temp
    try
        labirint_traversal!(robot) do
            if temperature(robot) == p
                throw("The End.")
            end
        end
    catch
        return
    end
end

t = LabirintRobot(AllCoordsRobot(CoordsRobot(Robot(animate=true, "26.sit"))))
v =  max_temperature!(t)
r = LabirintRobot(AllCoordsRobot(CoordsRobot(Robot(animate=true, "26.sit"))))
find_max_temperature!(r, v)

sleep(100)
