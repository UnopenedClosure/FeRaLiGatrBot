Subgoal={}

function Subgoal.waitFrames(n)
  return
    {
      name = "wait " .. n .. " frames",
      numFrames = n
    }
end

function Subgoal.pressButton(i, n)
  return
    {
      name = "press " .. i,
      numFrames = n,
      inputs = i
    }
end

function Subgoal.getOnBike()
  return
    {
      name = "get on bike",
      targetState = {
        TargetState.spriteIsOnBike()
      },
      numFrames = 5,
      permittedInputs = {"Select"}
    }
end

function Subgoal.startSurfing()
  return
  {
    name = "start surfing",
    targetState = {
      {
        register = 0x2036e3d,
        numBytes = 1,
        expectedValue = 2,
      }
    },
    numFrames = 240,
    permittedInputs = {"A"}
  }
end

function Subgoal.textbox(txt, numF, inputs)
  numF = numF or 50
  inputs = inputs or {"A"}
  toReturn = {
    name = "check for text " .. '"' .. txt .. '"',
    targetState = {},
    numFrames = numF,
    permittedInputs = inputs
  }
  for i = 1, #txt do
    table.insert(toReturn[targetState],
      {
        register = 0x2021d18,
        numBytes = 1,
        expectedValue = CharMapping[txt:sub(i,i)]
      }
    )
  end
  
  return toReturn
end

--[[function Subgoal.startOfBattle(slot1poke, numF)
  return {
          name = "start fight",
          targetState = {
            {
              expectedSlot1Poke = slot1Poke
            }
          },
          numFrames = numF,
          permittedInputs = {"A"}
         }
end--]]