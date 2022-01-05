dofile ("Utils.lua")
dofile ("Data.lua")
dofile ("TargetState.lua")
dofile ("Subgoal.lua")
dofile ("Route.lua")

if not isdir("log") then
  os.execute("mkdir log")
end
local log_file = io.open(os.date("log/branches_%Y%m%d%H%M%S.lua"), "a")
io.output(log_file)
local loglevel="DEBUG"

--TODO add dead-end indication logic?????
--TODO load possible branches from the generated branches_YYYYMMDDHHMMSS.lua

function runTest(inps, runToFrame, targetStates)
  tastudio.loadbranch(0)
  for g, a in pairs(inps) do
    if a ~= "NO_INPUT" then
      tastudio.submitinputchange(g, a, true)
    end
  end
  tastudio.applyinputchanges()
  advanceToFrame(runToFrame)
  local stillValid = true
  local idx = 1
  local targetState = nil
  while stillValid and (idx <= table.getn(targetStates)) do
    targetState = targetStates[idx]
    --TODO search for one of several expectedValues (e.g. manipping for one of a few trainer IDs)
    stillValid = (read(targetState["register"], targetState["numBytes"]) == targetState["expectedValue"])    
    idx = idx + 1
  end
  return stillValid
end

local subgoals = Route.subgoals
local maxFrame = Route.startFrame + Route.totalMaxFrames

tastudio.setrecording(false)
tastudio.loadbranch(0)
advanceToFrame(Route.startFrame)
local currentFrame = emu.framecount()

viableBranches = {} -- all branches that have successfully reached the targetStates by maxFrameForSubgoal
possibleBranches = { -- all branches that have not yet failed to reach the targetStates by maxFrameForSubgoal
  {
    startFrame = currentFrame,
    frame = currentFrame,
    inputs = {}
  }
}

local startTime = os.clock()
local passCount = 0
local subgoalCount = table.getn(subgoals)
log("subgoalCount = " .. subgoalCount)
for index, subgoal in pairs(subgoals) do
  console.clear()
  local waitInd1 = string.find(subgoal["name"], "wait ")
  if waitInd1 then
    local waitInd2 = string.find(subgoal["name"], " frames")
    if waitInd2 ~= null then
      local numF = string.sub(subgoal["name"], 6, (waitInd2 - 1))
      for i, branch in pairs(possibleBranches) do
        local startF = branch["startFrame"]
        for m=1, tonumber(numF), 1 do
          branch["inputs"][startF + m - 1] = "NO_INPUT"
        end
        branch["startFrame"] = startF + numF
        branch["frame"] = branch["frame"] + numF
        table.insert(viableBranches, branch)
      end
    end
  else
    local permittedInputs = subgoal["permittedInputs"]    
    while table.getn(possibleBranches) ~= 0 do
      local x = table.getn(possibleBranches)
      for j = x, 1, -1 do
        for k, inp in pairs(permittedInputs) do
        --TODO handle frames with more than one input (e.g. running)
          local prefix = "Subgoal " .. index .. " of " .. subgoalCount .. ", j.k = " .. j .. "." .. k .. ", "
          local branchStatus = ""--TODO fix minor bug which sometimes keeps this blank
          local maxFrameForSubgoal = possibleBranches[j]["startFrame"] + subgoal["numFrames"]
          if maxFrameForSubgoal > maxFrame then
            maxFrameForSubgoal = maxFrame
          end
          if possibleBranches[j]["frame"] >= maxFrameForSubgoal then
            table.remove(possibleBranches, j)
            branchStatus = "branch was removed"
            break
          else
            local f = possibleBranches[j]["frame"]
            local i = deepcopy(possibleBranches[j]["inputs"])
            local delimitedInputs = split(inp)
            for q, r in pairs(delimitedInputs) do
              i[f] = r
              f = f + 1
            end
            if f <= maxFrameForSubgoal then
              local newBranch = {
                startFrame = possibleBranches[j]["startFrame"],
                frame = f,
                inputs = i
              }
              if runTest(i, newBranch["frame"], subgoal["targetState"]) then
                table.insert(viableBranches, newBranch)
                branchStatus = "branch was viable"
              else
                table.insert(possibleBranches, newBranch)
                branchStatus = "branch was not yet viable"
              end
            end
          end
          print(prefix .. branchStatus .. ", " .. table.getn(viableBranches) .. " viable branches, " .. table.getn(possibleBranches) .. " possible branches")          
          passCount = passCount + 1
          if passCount % 1000 == 0 then
         --   console.clear()
            displayTimeElapsed(startTime)
          end
        end
        if possibleBranches[j] ~= nil then
          possibleBranches[j]["inputs"][possibleBranches[j]["frame"]] = "NO_INPUT"
          possibleBranches[j]["frame"] = possibleBranches[j]["frame"] + 1
        end
      end
    end
  end
  
  --TODO performance improvement? - maintain two pointers and swap them, instead of deep-copying the tables  
  if index ~= table.getn(subgoals) then
    possibleBranches = deepcopy(viableBranches)
    for i, branch in pairs(possibleBranches) do
      branch["startFrame"] = branch["frame"]
    end
    viableBranches = {}
  end 
  collectgarbage()
end
displayTimeElapsed(startTime)

--TODO sort branches by fewest inputs????
--TODO unfinished work - fix generated lua file's input keys (I think this is done, but I haven't tested it yet)

function printBranchesToFile(t, level, inputsFlag)
  level = level or 0
  --TODO print inputs in order????
  for key, value in pairs(t) do
    toPrint = ""
    for i = 1, level,1 do
      toPrint = toPrint .. '\t'
    end
    toPrint = toPrint .. '[' .. key .. '] = "'
    if type(value) == "table" then
      log(toPrint .. "{")
      if key == "inputs" then
        printBranchesToFile(value, level + 1, true)
      else
        printBranchesToFile(value, level + 1, false)
      end
      log("\t\t}")
    else
      toPrint = toPrint .. tostring(value) .. '",'
      log(toPrint)
    end
  end
end

-- list the surviving possibleBranches
--TODO sort the branches in ascending order by frame before printing????
log("possibleBranches = {")
for k, viableBranch in pairs(viableBranches) do
  log("{", 1)
  printBranchesToFile(viableBranch, 2)
  log("},", 1)
end
log("}")
io.close(log_file)

client.pause()
