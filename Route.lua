-- targetStates and subgoals which are used frequently
-- are defined in separate files for clarity and
-- repeatability

Route = {
  startFrame = 491203,
  totalMaxFrames = 53,
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
  }
}