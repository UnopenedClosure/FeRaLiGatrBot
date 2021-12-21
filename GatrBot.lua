dofile("Utils.lua")
dofile ("Route.lua")

if not isdir("log") then
  os.execute("mkdir log")
end
log_file = io.open(os.date("log/output_%Y%m%d%H%M%S.log"), "a")
io.output(log_file)
loglevel="DEBUG"

function runTest(inputs, runToFrame, targetStates)
  tastudio.loadbranch(0)
  for f, i in pairs(inputs) do--TODO logic to handle multi-inputs
    if i ~= "NO_INPUT" then
      tastudio.submitinputchange(f, i, true)
    end
  end
  tastudio.applyinputchanges()
  
  while emu.framecount() < runToFrame do
    emu.frameadvance()
  end
  
  stillValid = true
  index = 1
  local targetState = nil
  while stillValid and (index <= table.getn(targetStates)) do
    targetState = targetStates[index]
    debug("inputs = ")
    debugTable(inputs, 1)
    debug("register = " .. targetState["register"])
    debug("numBytes = " .. targetState["numBytes"])
    debug("expectedValue = " .. targetState["expectedValue"])
    debug("actualValue = " .. read(targetState["register"], targetState["numBytes"]))
    stillValid = (read(targetState["register"], targetState["numBytes"]) == targetState["expectedValue"])    
    if stillValid then
      debug("Passed targetState " .. index)
    else
      debug("Failed targetState " .. index)
    end
    index = index + 1
  end
  return stillValid
end

tastudio.setrecording(false)

subgoals = Route.subgoals
maxFrame = Route.startFrame + Route.totalMaxFrames

tastudio.loadbranch(0)
while emu.framecount() < Route.startFrame do
  emu.frameadvance()
end
currentFrame = emu.framecount()

log("Initial frame " .. Route.startFrame)
log("Searching until frame " .. maxFrame)
log(table.getn(subgoals) .. " subgoals to achieve")

viableBranches = {} -- all branches that have successfully reached the targetStates by maxFrameForSubgoal
possibleBranches = { -- all branches that have not yet failed to reach the targetStates by maxFrameForSubgoal
  {
    startFrame = currentFrame,
    frame = currentFrame,
    inputs = {}
  }
}

for index, subgoal in pairs(subgoals) do
  log("\nSubgoal " .. index .. ": " .. subgoal["name"])
  inputs = subgoal["permittedInputs"]
  debug("Possible Inputs:", 1)
  debugTable(inputs, 2)
  log("")
  
  while table.getn(possibleBranches) ~= 0 do
    x = table.getn(possibleBranches)
    for j = x, 1, -1 do
      for k, inp in pairs(inputs) do
        maxFrameForSubgoal = possibleBranches[j]["startFrame"] + subgoal["numFrames"]--TODO tweak this logic for when we are not on the first subgoal
        if maxFrameForSubgoal > maxFrame then
          maxFrameForSubgoal = maxFrame
        end
        if possibleBranches[j]["frame"] >= maxFrameForSubgoal then
          table.remove(possibleBranches, j)
        else
          f = possibleBranches[j]["frame"]
          i = deepcopy(possibleBranches[j]["inputs"])
          i[f] = inp --I will defer handling multi-inputs (e.g. holding B and moving to run) to the runTest function
          newBranch = {
            startFrame = possibleBranches[j]["startFrame"],
            frame = f + 1,
            inputs = i
          }
          
          if runTest(i, newBranch["frame"], subgoal["targetState"]) then
            debug("Successful Inputs", 1)
            debugTable(newBranch, 1)
            table.insert(viableBranches, newBranch)
          else 
            debug("Not-yet-successful Inputs", 1)
            debugTable(newBranch, 1)
            table.insert(possibleBranches, newBranch)
          end
          
          possibleBranches[j]["inputs"][f] = "NO_INPUT"
          possibleBranches[j]["frame"] = possibleBranches[j]["frame"] + 1
          debug("possibleBranches[" .. j .. "]:", 1)
          debugTable(possibleBranches[j], 1)
          --is there ever a case where I would want to test after adding a no-input?
        end
      end
    end
  end
  
  log("There are " .. table.getn(viableBranches) .. " options after subgoal " .. index)
  debugTable(viableBranches, 1)
  
  if index ~= table.getn(subgoals) then--TODO maybe use extra pointers that swap at the end, so that we don't have to run this deepcopy?
    possibleBranches = deepcopy(viableBranches)
    viableBranches = {}
  end
  
  --TODO should we garbage collect at the end of this loop?
end

--TODO prune branches by which ones end soonest
--TODO sort (and maybe prune?) branches by fewest inputs?

-- summarize the surviving possibleBranches
--TODO maybe once there are longer (and fewer) branches, a CSV view would be more helpful?
log("\Viable Branches at end of search:")
for k, viableBranch in pairs(viableBranches) do
  log("Branch " .. k)
  totalFrames = viableBranch["frame"] - Route.startFrame
  log("Total Frames:" .. totalFrames, 1)
  log("Inputs:", 1)
  index = Route.startFrame
  while index < viableBranch["frame"] do
    log(index .. ":" .. viableBranch["inputs"][index], 2)    
    index = index + 1
  end
  log("")
end

io.close(log_file)