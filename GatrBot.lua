dofile ("Utils.lua")
dofile ("Data.lua")
dofile ("TargetState.lua")
dofile ("Subgoal.lua")

--routefile and WIPfile go here
dofile ("Route - Five Isle Meadow.lua")
--dofile ("Route.lua")
--dofile ("Route - testing failure conditions.lua")
--local branchesWIPFile = "log/branches_20220106192441.lua"
--local branchesWIPFile = nil
local branchesWIPFile = "log/branches_20220110133244.lua"
branchNum = 13
if not branchNum then
  branchNum = 0
end

--TODO migrate more logging setup inside of Utils.java
if not isdir("log") then
  os.execute("mkdir log")
end
local log_file = io.open(os.date("log/branches_%Y%m%d%H%M%S.lua"), "a")
io.output(log_file)
local loglevel="DEBUG"
local logfrequency = 1

function checkStates(states)
  local stillValid = true
  local idx = 1
  while stillValid and (idx <= table.getn(states)) do
    local targetState = states[idx]
    local actualValue = read(targetState["register"], targetState["numBytes"], targetState["bigEndianFlag"])
    local expectedValue = targetState["expectedValue"]
    if type(expectedValue) == "table" then
      local foundMatch = false
      for n, ev in pairs(expectedValue) do
        if actualValue == ev then
          foundMatch = true
          break
        end
      end
      stillValid = foundMatch
    else
      stillValid = (actualValue == expectedValue)
    end
    idx = idx + 1
  end
  return stillValid
end

function runTest(inps, runToFrame, targetStates)
  tastudio.loadbranch(branchNum)
  for g, a in pairs(inps) do
    if a ~= "NO_INPUT" then
      tastudio.submitinputchange(g, a, true)
    end
  end
  tastudio.applyinputchanges()
  advanceToFrame(runToFrame)
  return checkStates(targetStates)
end

--TODO move the setup ahead of the functions????
tastudio.setrecording(false)
client.invisibleemulation(false)
--TODO once this issue gets addressed (https://github.com/TASEmulators/BizHawk/issues/1161), save a branch to use for botting instead of branch 0
tastudio.loadbranch(branchNum)
advanceToFrame(Route.startFrame)
local currentFrame = emu.framecount()
local firstSubgoal = 1
local timeElapsed = 0
successfulBranches = {} -- all branches that have successfully reached the targetStates by maxFrameForSubgoal

if branchesWIPFile ~= nil then
  dofile(branchesWIPFile)
  firstSubgoal = Branches.subgoalCount + 1
  candidateBranches = Branches.successfulBranches
  timeElapsed = Branches.timeElapsed
  local mess = "loaded " .. table.getn(candidateBranches) .. " branches from " .. branchesWIPFile
  print(mess)
  log("-- " .. mess)
else
  candidateBranches = { -- all branches that have not yet failed to reach the targetStates by maxFrameForSubgoal
    {
      startFrame = currentFrame,
      frame = currentFrame,
      inputs = {}
    }
  }
end

local startTime = os.clock()--TODO migrate this inside of Utils???
local passCount = 0
local maxFrame = Route.startFrame + Route.totalMaxFrames
local subgoals = Route.subgoals
local subgoalCount = table.getn(subgoals)
log("Branches = {}")
log("Branches.subgoalCount = " .. subgoalCount)
for index, subgoal in pairs(subgoals) do
  if index < firstSubgoal then
    print("Subgoal " .. index .. " of " .. subgoalCount .. " already finished, moving on...")
  else
    if string.find(subgoal["name"], "wait ") then
      local numF = subgoal["numFrames"]
      for n, branch in pairs(candidateBranches) do
        local startF = branch["startFrame"]
        for m = 1, tonumber(numF), 1 do
          branch["inputs"][startF + m - 1] = "NO_INPUT"
        end
        branch["startFrame"] = startF + numF
        branch["frame"] = branch["frame"] + numF
        table.insert(successfulBranches, branch)
      end
    else
      if string.find(subgoal["name"], "press ") then
        for i, branch in pairs(candidateBranches) do
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
            table.insert(successfulBranches, newBranch)
          end
        end
      else
        local permittedInputs = subgoal["permittedInputs"]
        while table.getn(candidateBranches) ~= 0 do
          local x = table.getn(candidateBranches)
          for j = x, 1, -1 do
            local numPossibleInputs = table.getn(permittedInputs)
            for k, inp in pairs(permittedInputs) do
            --TODO handle frames with more than one input (e.g. running)
              local branchCount = (j * numPossibleInputs) + numPossibleInputs - k
              local prefix = "Subgoal " .. index .. " of " .. subgoalCount .. ", branches to check = " .. branchCount .. ", "
              local branchStatus = ""
              local maxFrameForSubgoal = candidateBranches[j]["startFrame"] + subgoal["numFrames"]
              if maxFrameForSubgoal > maxFrame then
                maxFrameForSubgoal = maxFrame
              end
              if candidateBranches[j]["frame"] >= maxFrameForSubgoal then
                table.remove(candidateBranches, j)
                branchStatus = "branch removed"
                break
              else
                local f = candidateBranches[j]["frame"]
                local i = deepcopy(candidateBranches[j]["inputs"])
                local delimitedInputs = split(inp)
                for q, r in pairs(delimitedInputs) do
                  i[f] = r
                  f = f + 1
                end
                if f <= maxFrameForSubgoal then
                  local newBranch = {
                    startFrame = candidateBranches[j]["startFrame"],
                    frame = f,
                    inputs = i
                  }
                  if runTest(i, newBranch["frame"], subgoal["targetState"]) then
                    if subgoal["failureState"] ~= nil then
                      if checkStates(subgoal["failureState"]) then
                        branchStatus = "branch failed"
                        break
                      end
                    end                     
                    newBranch["startFrame"] = newBranch["frame"]
                    table.insert(successfulBranches, newBranch)
                    branchStatus = "branch successful"
                  else
                    branchStatus = "branch not yet successful"
                    if subgoal["failureState"] ~= nil then
                      if checkStates(subgoal["failureState"]) then
                        branchStatus = "branch failed"
                      end
                    else
                      table.insert(candidateBranches, newBranch)
                    end
                  end
                end
              end
              if branchCount % logfrequency == 0 and branchStatus ~= "" then
                print(prefix .. branchStatus .. ", " .. table.getn(successfulBranches) .. " successful branches, " .. table.getn(candidateBranches) .. " candidate branches")          
              end
              passCount = passCount + 1
              if passCount % 500 == 0 then
                console.clear()
                displayTimeElapsed(startTime)
              end
            end
            if candidateBranches[j] ~= nil then
              candidateBranches[j]["inputs"][candidateBranches[j]["frame"]] = "NO_INPUT"
              candidateBranches[j]["frame"] = candidateBranches[j]["frame"] + 1
            end
          end
        end
      end
    end  
    --TODO write the branches.lua after each subgoal instead of at the very end
    --TODO performance improvement? - maintain two pointers and swap them, instead of deep-copying the tables
    if index ~= table.getn(subgoals) then
      candidateBranches = deepcopy(successfulBranches)
      for i, branch in pairs(candidateBranches) do
        branch["startFrame"] = branch["frame"]
      end
      successfulBranches = {}
    end
    console.clear() 
    collectgarbage()
  end
end
displayTimeElapsed(startTime)

--TODO group all of the functions together???
function printBranchesToFile(t, level, inputsFlag)
  level = level or 0
  inputsFlag = inputsFlag or false
  if inputsFlag then
    for key, value in pairsByKeys(t) do
      toPrint = string.rep("\t", level) .. '[' .. key .. '] = "' .. tostring(value) .. '",'
      log(toPrint)
    end
  else
    for key, value in pairs(t) do
      toPrint = string.rep("\t", level)
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

function countInputs(tab)
  local toReturn = 0
  for u, v in pairs(tab) do
    if v ~= "NO_INPUT" then
      toReturn = toReturn + 1
    end
  end
  return toReturn
end

function sortedBranches(tab)
   local keys = {}
   for k in pairs(tab) do
      keys[#keys + 1] = k
   end
   table.sort(keys, function(a, b)
                      if tab[a]["startFrame"] == tab[b]["startFrame"] then
                        return countInputs(tab[a]) < countInputs(tab[b])
                      else
                        return tab[a]["startFrame"] < tab[b]["startFrame"]
                      end
                    end)
   local j = 0
   return function()
            j = j + 1
            local k = keys[j]
            if k ~= nil then
              return k, tab[k]
            end
          end
end

-- persist successfulBranches for future searching
log("Branches.successfulBranches = {")
for k, viableBranch in sortedBranches(successfulBranches) do
  log("{", 1)
  printBranchesToFile(viableBranch, 2)
  log("},", 1)
end
log("}")

displayTimeElapsed(startTime, timeElapsed)
io.close(log_file)--TODO can I set this up to execute when the script ends? or will it execute when the script ends anyway?
client.pause()
