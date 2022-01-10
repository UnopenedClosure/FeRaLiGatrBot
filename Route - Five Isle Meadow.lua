-- targetStates and subgoals which are used frequently
-- are defined in separate files for clarity and
-- repeatability

Route = {
  startFrame = 524113,
  totalMaxFrames = 47 + 16 + 16 + 75 + 2 + 12,--168
--  totalMaxFrames = 645, -- this will be the total frames allowed for meeting all subgoals

-- Subgoals are achieved from first to last
  subgoals = {
    {--subgoal 1 
      name = "turn around",
      targetState = {
        TargetState.yCoord(11),
        TargetState.direction("Up")
      },
      numFrames = 47,
      permittedInputs = {"Down,Up"}
    },
    {--subgoal 2
      name = "go towards harbor door",
      targetState = {
        TargetState.yCoord(10)
      },
      numFrames = 16,
      permittedInputs = {"NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Up"}
    },
    {--subgoal 3
      name = "leave harbor",
      targetState = {
        TargetState.yCoord(9)
      },
      numFrames = 16,
      permittedInputs = {"NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Up"}
    },
    Subgoal.waitFrames(75),--subgoal 4
    {--subgoal 5
      name = "go up",
      targetState = {
        TargetState.yCoord(20),
        TargetState.direction("Up"),
        TargetState.spriteIsOnBike()
      },
      numFrames = 12,
      permittedInputs = {"Select,Up"}
    },
--[[    {--subgoal 6
      name = "go up and right",
      targetState = {
        TargetState.xCoord(20),
        TargetState.yCoord(19),
      },
      numFrames = 57,
      failureState = {
        TargetState.xCoord(19)
      },
      permittedInputs = {"NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Up", "NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Right"}
    },--]]
--[[    {
      name = "go right",
      targetState = {
        TargetState.xCoord(8)
      },
      numFrames = 121,
      permittedInputs = {"NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Right"}
    },--]]
 --[[   {
      name = "go up and right",
      targetState = {
        TargetState.xCoord(11),
        TargetState.yCoord(15),
      },
      numFrames = 89,
      permittedInputs = {"NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Up", "NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Right"}
    },--]]
--[[    {
      name = "pass first spinner, part 1",
      targetState = {
        TargetState.xCoord(15)
      },
      numFrames = 86,
      failureState = {
        TargetState.xCoord(25)
      },
      permittedInputs = {"NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Up", "NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Right"}
    },--]]
--[[    {
      name = "pass first spinner, part 2",
      targetState = {
        TargetState.xCoord(20)
      },
      numFrames = 88,
      failureState = {
        TargetState.xCoord(25)
      },
      permittedInputs = {"NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Up", "NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Right", "NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Down"}
    },--]]
--[[    {
      name = "pass first spinner, part 3",
      targetState = {
        TargetState.xCoord(24),
        TargetState.yCoord(15),
      },
      numFrames = 54,
      failureState = {
        TargetState.xCoord(25)
      },
      permittedInputs = {"NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Up", "NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Right", "NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Down"}
    },--]]
--[[    {
      name = "approach easy spinner",
      targetState = {
        TargetState.xCoord(23),
        TargetState.yCoord(21),
      },
      numFrames = 93,
      failureState = {
        TargetState.xCoord(22)
      },
      permittedInputs = {"NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Left", "NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Down"}
    },--]]
--[[    {
      name = "pass easy spinner",
      targetState = {
        TargetState.xCoord(26),
        TargetState.yCoord(39),
      },
      numFrames = 173,
      failureState = {
        TargetState.xCoord(27)
      },
      permittedInputs = {"NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Right", "NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Down"}
    },--]]
--[[    {
      name = "go left",
      targetState = {
        TargetState.xCoord(23)
      },
      numFrames = 63,
      permittedInputs = {"NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Left"}
    },--]]
--[[    {
      name = "go towards stairs, part 1",
      targetState = {
        TargetState.xCoord(20)
      },
      numFrames = 69,
      permittedInputs = {"NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Left","NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Up"}
    },--]]
--[[    {
      name = "go towards stairs, part 2",
      targetState = {
        TargetState.yCoord(38)
      },
      numFrames = 63,
      failureState = {
        TargetState.xCoord(18)
      },
      permittedInputs = {"NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Left","NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Up"}
    },--]]
--[[    {
      name = "go onto stairs",
      targetState = {
        TargetState.yCoord(37)
      },
      numFrames = 51,
      permittedInputs = {"NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Up"}
    },--]]
--[[    {
      name = "go towards grunt",
      targetState = {
        TargetState.xCoord(18),
        TargetState.yCoord(35),
        TargetState.direction("Up"),
      },
      numFrames = 71,
      failureState = {
        TargetState.xCoord(18)
      },
      permittedInputs = {"NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Left","NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Up"}
    },--]]
--[[    Subgoal.textbox("There", 13, {"NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,A,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT"}),
--]]
  }
}