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

--TODO rename files and remove old lua files
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

--TODO prune branches by which ones take longest????
--TODO sort (and maybe prune?) branches by fewest inputs?
--TODO fix generated lua file's input keys

-- list the surviving possibleBranches
log("possibleBranches = {")
for k, viableBranch in pairs(viableBranches) do
  log("{", 1)
  logTable(viableBranch, 2)
  log("},", 1)
end
log("}")
io.close(log_file)

client.pause()
