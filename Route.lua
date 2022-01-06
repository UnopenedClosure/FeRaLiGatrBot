-- targetStates and subgoals which are used frequently
-- are defined in separate files for clarity and
-- repeatability

Route = {
  startFrame = 530,
  totalMaxFrames = 380,

-- Subgoals are achieved from first to last
  subgoals = {
    Subgoal.waitFrames(4),
    Subgoal.pressButton("Start", 15),
    Subgoal.waitFrames(60),
    Subgoal.pressButton("A", 15),
    Subgoal.waitFrames(156),
    Subgoal.pressButton("Start", 15),
    Subgoal.waitFrames(109),
    {
      name = "set Trainer ID",
      targetState = {
        {
          register = 0xD358,
          numBytes = 2,
          bigEndianFlag = true,
          expectedValue = {0x6411, 0x6413, 0x6415, 0x6416, 0x6417, 0x641A, 0x641B, 0x641D, 0x645A, 0x6471, 0x6476, 0x64CF, 0x64D0, 0x64EA}
          --expectedValue = 30753
        }
      },
      numFrames = 31 + 15,--fifteen frames of delay, plus the 31 frames for the inputs below
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