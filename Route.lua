-- targetStates and subgoals which are used frequently
-- are defined in separate files for clarity and
-- repeatability

Route = {
  startFrame = 530,
  totalMaxFrames = 420,
--  totalMaxFrames = 9500, -- this is the total frames allowed for meeting all subgoals
--allow 255 frames for first movement inside PC

-- Subgoals are achieved from first to last
  subgoals = {
    Subgoal.waitFrames(4),
    Subgoal.pressButton("Start", 3),
    Subgoal.waitFrames(60),
    Subgoal.pressButton("A", 3),
    Subgoal.waitFrames(156),
    Subgoal.pressButton("Start", 3),
    Subgoal.waitFrames(109),
    {
      name = "set Trainer ID",
      targetState = {
        {
          register = 0xD358,
          numBytes = 2,
          bigEndianFlag = true,
          expectedValue = 30753
        }
      },
      numFrames = 35,
      permittedInputs = {"A,NO_INPUT,NO_INPUT," ..
                         "NO_INPUT,NO_INPUT,NO_INPUT," ..
                         "NO_INPUT,NO_INPUT,NO_INPUT," ..
                         "NO_INPUT,NO_INPUT,NO_INPUT," ..
                         "NO_INPUT,NO_INPUT,NO_INPUT," ..
                         "NO_INPUT,NO_INPUT,NO_INPUT," ..
                         "NO_INPUT,NO_INPUT,NO_INPUT," ..
                         "NO_INPUT,NO_INPUT,NO_INPUT," ..
                         "NO_INPUT,NO_INPUT,NO_INPUT," ..
                         "NO_INPUT,NO_INPUT,NO_INPUT," ..
                         "NO_INPUT"}
    }
  }
}