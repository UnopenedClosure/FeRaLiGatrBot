-- targetStates and subgoals which are used frequently
-- are defined in separate files for clarity and
-- repeatability

Route = {
  startFrame = 491203,
  totalMaxFrames = 98,
--  totalMaxFrames = 9500, -- this is the total frames allowed for meeting all subgoals
--allow 255 frames for first movement inside PC

-- Subgoals are achieved from first to last
  subgoals = {
    Subgoal.getOnBike(),
    {
      name = "go up",
      targetState = {
        TargetState.yCoord(24),
        TargetState.direction("Up")
      },
      numFrames = 1,
      permittedInputs = {"Up"}
    },
    {
      name = "go towards stairs",
      targetState = {
        TargetState.yCoord(23)
      },
      numFrames = 14,
      permittedInputs = {"NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Up", "NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Right"}
    },
    {
      name = "go onto stairs",
      targetState = {
        TargetState.yCoord(22),
      },
      numFrames = 14,
      permittedInputs = {"NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Up", "NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Right"}
    },
    {
      name = "go up stairs",
      targetState = {
        TargetState.yCoord(21),
      },
      numFrames = 14,
      permittedInputs = {"NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Up", "NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Right"}
    },
    Subgoal.waitFrames(2),
    {
      name = "go past stairs",
      targetState = {
        TargetState.yCoord(20),
      },
      numFrames = 14,
      permittedInputs = {"NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Up", "NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Right"},
      failureState = {
        TargetState.xCoord(21),
        TargetState.yCoord(21)
      }
    },
    {
      name = "go past sign",
      targetState = {
        TargetState.yCoord(19),
      },
      numFrames = 14,
      permittedInputs = {"NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Up", "NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Right"}
    },
    {
      name = "go past old guy",
      targetState = {
        TargetState.yCoord(18),
      },
      numFrames = 14,
      permittedInputs = {"NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Up", "NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Right"},
      failureState = {
        TargetState.xCoord(20)
      }
    },
    {
      name = "go towards bald guy",
      targetState = {
        TargetState.yCoord(17),
      },
      numFrames = 14,
      permittedInputs = {"NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Up", "NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Right"},
      failureState = {
        TargetState.xCoord(20)
      }
    },
    {
      name = "go parallel to bald guy",
      targetState = {
        TargetState.yCoord(16),
      },
      numFrames = 14,
      permittedInputs = {"NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Up", "NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Right"},
      failureState = {
        TargetState.xCoord(20)
      }
    },
    {
      name = "go past bald guy",
      targetState = {
        TargetState.yCoord(15),
      },
      numFrames = 14,
      permittedInputs = {"NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Up", "NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Right"},
      failureState = {
        TargetState.xCoord(20)
      }
    },
    {
      name = "go onto stairs",
      targetState = {
        TargetState.yCoord(14),
        TargetState.xCoord(21)
      },
      numFrames = 21,
      permittedInputs = {"NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Up", "NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Right"},
      failureState = {
        TargetState.xCoord(20)
      }
    },
    {
      name = "go to PC door",
      targetState = {
        TargetState.map("OneIsland"),
        TargetState.xCoord(21),
        TargetState.yCoord(13),
        TargetState.direction("Up")
      },
      numFrames = 7,
      permittedInputs = {"NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Up"}
    },
    Subgoal.waitFrames(2),
    {
      name = "go into PC",
      targetState = {
        TargetState.yCoord(12)
      },
      numFrames = 7,
      permittedInputs = {"NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,NO_INPUT,Up"}
    },
  }
}