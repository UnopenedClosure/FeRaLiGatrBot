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
    local expectedValue = targetState["expectedValue"]
    if type(expectedValue) == "table" then
      local actualValue = read(targetState["register"], targetState["numBytes"], targetState["bigEndianFlag"])
      local foundMatch = false
      for n, ev in pairs(expectedValue) do
        if actualValue == ev then
          foundMatch = true
          break
        end
      end
      stillValid = foundMatch
    else
      stillValid = (read(targetState["register"], targetState["numBytes"], targetState["bigEndianFlag"]) == expectedValue)
    end
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
    local pressInd = string.find(subgoal["name"], "press ")
    if pressInd then
      for i, branch in pairs(possibleBranches) do
        for j = 0, subgoal["numFrames"] - 1, 1 do
          local inps = deepcopy(branch["inputs"])
          local f = branch["startFrame"]
          local frameForInput = f + j
          while f < frameForInput do
            inps[f] = "NO_INPUT"
            f = f + 1
          end
          inps[f] = subgoal["inputs"]
          local newBranch = {
            startFrame = f + 1,
            frame = f + 1,
            inputs = inps
          }
          table.insert(viableBranches, newBranch)
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
            local branchStatus = ""
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
                --TODO pretty sure I need to set startFrame to f here
                  table.insert(viableBranches, newBranch)
                  branchStatus = "branch was viable"
                else
                  table.insert(possibleBranches, newBranch)
                  branchStatus = "branch was not yet viable"
                end
              else
                branchStatus = "branch about to be removed"
              end
            end
            print(prefix .. branchStatus .. ", " .. table.getn(viableBranches) .. " viable branches, " .. table.getn(possibleBranches) .. " possible branches")          
            passCount = passCount + 1
            if passCount % 1000 == 0 then
              console.clear()
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
  inputsFlag = inputsFlag or false
  if inputsFlag then
    for key, value in pairsByKeys(t) do
      toPrint = ""
      for i = 1, level,1 do
        toPrint = toPrint .. '\t'
      end
      toPrint = toPrint .. '[' .. key .. '] = "' .. tostring(value) .. '",'
      log(toPrint)
    end
  else
    for key, value in pairs(t) do
      toPrint = ""
      for i = 1, level,1 do
        toPrint = toPrint .. '\t'
      end
      if inputsFlag then
        toPrint = toPrint .. '[' .. key .. '] = "'
      else
        toPrint = toPrint .. key .. ' = '
      end
      if type(value) == "table" then
        log(toPrint .. "{")
        printBranchesToFile(value, level + 1, key == "inputs")
        log("\t\t}")
      else
        toPrint = toPrint .. tostring(value) .. ','
        log(toPrint)
      end
    end
  end
end

function sortedBranches(tab)
   local keys = {}
   for k in pairs(tab) do
      keys[#keys + 1] = k
   end
   table.sort(keys, function(a, b) return tab[a]["startFrame"] < tab[b]["startFrame"] end)
   local j = 0
   return
      function()
         j = j + 1
         local k = keys[j]
         if k ~= nil then
            return k, tab[k]
         end
      end
end

-- list the surviving possibleBranches
log("possibleBranches = {")
for k, viableBranch in sortedBranches(viableBranches) do
  log("{", 1)
  printBranchesToFile(viableBranch, 2)
  log("},", 1)
end
log("}")
io.close(log_file)

client.pause()
