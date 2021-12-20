dofile ("Data.lua")
dofile ("Subgoal.lua")

-- targetStates and subgoals which are used frequently
-- are defined in separate files for clarity and
-- repeatability

Route = {
  startFrame = 491200,
  totalMaxFrames = 9500, -- this is the total frames allowed for meeting all subgoals

-- Subgoals are achieved from first to last
--                    
-- After all successConditions have been met,
-- we will choose the shortest option
  subgoals = {
    Subgoal.getOnBike(),
--[[    {
      name = "navigate to Pokemon Center",
      targetState = {
        TargetState.map("OneIsland"),
        TargetState.xCoord(21),
        TargetState.yCoord(13),
        TargetState.direction("Up")
      },
      numFrames = 200,
      permittedInputs = {Up=true, Right=true}
    },--]]
--[[    {
      name = "enter Pokemon Center",-- checking to see if bike dismount is faster
      targetState = {
        TargetState.map("OneIsland_PokemonCenter_1F"),
        TargetState.xCoord(16),
        TargetState.yCoord(15)
      },
      numFrames = 180,
      permittedInputs = {Select=true, Up=true}
    },
    {
      name = "move to Celio",
      targetState = {
        TargetState.xCoord(21),
        TargetState.yCoord(13),
        TargetState.direction("Right")
      },
      numFrames = 140,
      permittedInputs = {Up=true, Right=true}
    },
    Subgoal.textbox("CELIO"),
    Subgoal.textbox("I'm", 200),
    Subgoal.textbox("But,", 210),
    {
      name = "end of Celio dialog",
      targetState = {
        TargetState.xCoord(20),
        TargetState.yCoord(13),
        TargetState.direction("Left")
      },
      numFrames = 200,
      permittedInputs = {A=true, Left=true}
    },
    {
      name = "exit Pokemon Center",
      targetState = {
        TargetState.map("OneIsland"),
        TargetState.xCoord(21),
        TargetState.yCoord(13),
        TargetState.direction("Down")
      },
      numFrames = 200,
      permittedInputs = {Down=true, Left=true}
    },
    Subgoal.getOnBike(),
    {
      name = "enter Kindle Road",
      targetState = {
        TargetState.map("OneIsland_KindleRoad"),
        TargetState.xCoord(10),
        TargetState.yCoord(139),
        TargetState.direction("Right")
      },
      numFrames = 120,
      permittedInputs = {Down=true, Right=true}
    },
    {
      name = "turn towards water",
      targetState = {
        TargetState.map("OneIsland_KindleRoad"),
        TargetState.yCoord(138)
      },
      numFrames = 8,
      permittedInputs = {Up=true}
    },
    Subgoal.startSurfing(),
    {
      name = "surf up to vertical path",
      targetState = {
        TargetState.xCoord(16),
        TargetState.yCoord(131),
        TargetState.direction("Up")
      },
      numFrames = 240,
      permittedInputs = {Up=true, Right=true}
    },
    {
      name = "get out of water and onto bike",
      targetState = {
        TargetState.yCoord(130),
        TargetState.spriteIsOnBike()
      },
      numFrames = 60,
      permittedInputs = {Up=true, Select=true}
    },
    {
      name = "use super repel",
      targetState = {
        {
          register = 0x2021d29,
          numBytes = 1,
          expectedValue = CharMapping["R"]
        },{
          register = 0x2021d2a,
          numBytes = 1,
          expectedValue = CharMapping["E"]
        },{
          register = 0x2021d2b,
          numBytes = 1,
          expectedValue = CharMapping["P"]
        },{
          register = 0x2021d2c,
          numBytes = 1,
          expectedValue = CharMapping["E"]
        },{
          register = 0x2021d2d,
          numBytes = 1,
          expectedValue = CharMapping["L"]
        },
      },
      numFrames = 150,
      permittedInputs = {Down=true, Start=true, Select=true, A=true, B=true}
    },
    {
      name = "leave menus",
      targetState = {
        TargetState.yCoord(129)
      },
      numFrames = 120,
      permittedInputs = {Up=true, B=true}
    },
    {
      name = "bike past spinners",
      targetState = {
        TargetState.xCoord(17),
        TargetState.yCoord(59),
        TargetState.direction("Up")
      },
      numFrames = 550,
      permittedInputs = {Up=true, Left=true, Right=true}
    },
    Subgoal.startSurfing(),
    {
      name = "surf past spinners",
      targetState = {
        TargetState.xCoord(16),
        TargetState.yCoord(26),
        TargetState.direction("Up")
      },
      numFrames = 270,
      permittedInputs = {Up=true, Left=true}
    },
    Subgoal.waitFrames(25),
    Subgoal.getOnBike(),
    {
      name = "bike to Mt. Ember",
      targetState = {
        TargetState.xCoord(18),
        TargetState.yCoord(13),
        TargetState.direction("Up")
      },
      numFrames = 100,
      permittedInputs = {Up=true, Right=true}
    },
    Subgoal.textbox("MT. EMBER", 80, {Up=true}),
    Subgoal.waitFrames(16),
    {
      name = "skip picture",
      targetState = {
        TargetState.map("MtEmber_Exterior"),
        TargetState.yCoord(54),
      },
      numFrames = 100,
      permittedInputs = {Up=true, B=true}
    },
    Subgoal.textbox("Whew,", 100, {Up=true, Right=true}),
    Subgoal.textbox("Any", 100),
    Subgoal.textbox("What,", 140),
    Subgoal.textbox("Hey", 190),
    Subgoal.textbox("What,", 140),
    Subgoal.textbox("What,", 140),
    Subgoal.textbox("What,", 140),
    Subgoal.waitFrames(35),
    {
      name = "end of Grunt dialog",
      targetState = {
        TargetState.yCoord(49),
      },
      numFrames = 10,
      permittedInputs = {A=true, Up=true}
    },
    {
      name = "move towards grunts",
      targetState = {
        TargetState.xCoord(48),
        TargetState.yCoord(48),
        TargetState.direction("Up")
      },
      numFrames = 30,
      permittedInputs = {Right=true, Up=true}
    },--]]
--[[Commenting these out for now because I haven't figured out this implementation yet
    Subgoal.startOfBattle("Cubone"),
    {
      name = "punch Cubone",
      targetState = {
        -- TODO check for remaining Mega Punch PP to be reduced by 1 and all other PP to be untouched
        -- TODO check for Cubone's remaining HP to be 0
      },
      numFrames = 760,
      permittedInputs = {A=true, Up=true, Down=true}
    },
    {
      name = "punch Marowak",
      targetState = {
        -- TODO check for remaining Mega Punch PP to be reduced by 1 and all other PP to be untouched
        -- TODO check for Marowak's remaining HP to be 0
      },
      numFrames = 640,
      permittedInputs = {A=true, Up=true, Down=true}
    },
    Subgoal.textbox("Why", 480),
    Subgoal.waitFrames(25),
    Subgoal.textbox("Trying,", 20, {Up=true, Right=true, A=true}),
    {
      name = "start fight",
      targetState = {
        -- TODO check for Rattata in enemy slot 1
      },
      numFrames = 180,
      permittedInputs = {A=true}
    },
    {
      name = "punch Rattata",
      targetState = {
        -- TODO check for remaining Mega Punch PP to be reduced by 1 and all other PP to be untouched
        -- TODO check for Rattata's remaining HP to be 0
      },
      numFrames = 760,
      permittedInputs = {A=true, Up=true, Down=true}
    },
    {
      name = "punch Raticate",
      targetState = {
        -- TODO check for remaining Mega Punch PP to be reduced by 1 and all other PP to be untouched
        -- TODO check for Raticate's remaining HP to be 0
      },
      numFrames = 680,
      permittedInputs = {A=true, Up=true, Down=true}
    },
    {
      name = "punch Sandshrew",
      targetState = {
        -- TODO check for remaining Mega Punch PP to be reduced by 1 and all other PP to be untouched
        -- TODO check for Sandshrew's remaining HP to be 0
      },
      numFrames = 680,
      permittedInputs = {A=true, Up=true, Down=true}
    },
    {
      name = "punch Sandslash",
      targetState = {
        -- TODO check for remaining Mega Punch PP to be reduced by 1 and all other PP to be untouched
        -- TODO check for Sandslash's remaining HP to be 0
      },
      numFrames = 680,
      permittedInputs = {A=true, Up=true, Down=true}
    },
    Subgoal.textbox("What a setback", 550),
    {
      name = "enter Mt. Ember",
      targetState = {
        TargetState.xCoord(49),
        TargetState.yCoord(46),
        TargetState.direction("Up")
      },
      numFrames = 220,--?????????????????
      permittedInputs = {A=true, Up=true}
    }
    --now we are inside the Mt. Ember interior--]]
  }
}