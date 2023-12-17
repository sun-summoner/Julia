using HorizonSideRobots
HSR = HorizonSideRobots
include("all.jl")

function whole_field!(robot::PutmarkersRobot)
    num_west_steps, num_sud_steps = go_along!(robot, West), go_along!(robot, Sud)
    snake!(robot, (Ost, Nord))
    go_along!(robot, West)
    go_along!(robot, Sud)
    go_steps!(robot, Ost, num_west_steps)
    go_steps!(robot, Nord, num_sud_steps)
end
r = Robot(animate=true, "3.sit")
q = PutmarkersRobot{Robot}(r)
whole_field!(q)
sleep(100)