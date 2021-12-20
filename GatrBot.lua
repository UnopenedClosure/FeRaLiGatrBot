dofile ("Route.lua")

function read(addr, size)
  mem = ""
  memdomain = bit.rshift(addr, 24)
  if memdomain == 0 then
    mem = "BIOS"
  elseif memdomain == 2 then
    mem = "EWRAM"
  elseif memdomain == 3 then
    mem = "IWRAM"
  elseif memdomain == 8 then
    mem = "ROM"
  end
  addr = bit.band(addr, 0xFFFFFF)
  if size == 1 then
    return memory.read_u8(addr,mem)
  elseif size == 2 then
    return memory.read_u16_le(addr,mem)
  elseif size == 3 then
    return memory.read_u24_le(addr,mem)
  else
    return memory.read_u32_le(addr,mem)
  end 
end

log_file = io.open(os.date("log/output_%Y%m%d%H%M%S.log"), "a")
io.output(log_file)
loglevel="DEBUG"

function log(txt)
  io.write(tostring(txt))
  io.write("\n")
--  print(txt)
end

function debug(txt)
  if loglevel=="DEBUG" then
    log(txt)
  end
end

function logTable(t, level)
  level = level or 0
  for key, value in pairs(t) do
    toPrint = ""
    for i = 0,level,1 do
      toPrint = toPrint .. '\t'
    end
    toPrint = toPrint .. key .. ":"
    if type(value) == "table" then
      log(toPrint)
      logTable(value, level + 1)
    else
      toPrint = toPrint .. tostring(value)
      log(toPrint)
    end
  end
end

function printTable(t, level)
  level = level or 0
  for key, value in pairs(t) do
    toPrint = ""
    for i = 0,level,1 do
      toPrint = toPrint .. '\t'
    end
    toPrint = toPrint .. key .. ":"
    if type(value) == "table" then
      print(toPrint)
      printTable(value, level + 1)
    else
      toPrint = toPrint .. tostring(value)
      print(toPrint)
    end
  end
end

function debugTable(t, level)
  if loglevel=="DEBUG" then
    level = level or 0
    logTable(t, level)
  end
end

function deepcopy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
    copy = {}
    for orig_key, orig_value in next, orig, nil do
        copy[deepcopy(orig_key)] = deepcopy(orig_value)
    end
    setmetatable(copy, deepcopy(getmetatable(orig)))
  else -- number, string, boolean, etc
    copy = orig
  end
  return copy
end

function runTest(inputs, targetStates)
  tastudio.loadbranch(0)
  runToFrame = -1
  for f, i in pairs(inputs) do--TODO logic to handle multi-inputs
    if i ~= "NO_INPUT" then
      tastudio.submitinputchange(f, i, true)
    end
    if f > runToFrame then
      runToFrame = f + 1
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
    debugTable(inputs)
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
  debugTable(inputs, 1)
  while table.getn(possibleBranches) ~= 0 do
    x = table.getn(possibleBranches)
    for j = x, 1, -1 do
      for k, inp in pairs(inputs) do
        maxFrameForSubgoal = possibleBranches[j]["startFrame"] + subgoal["numFrames"]
        if maxFrameForSubgoal > maxFrame then
          maxFrameForSubgoal = maxFrame
        end
        if possibleBranches[j]["frame"] >= maxFrameForSubgoal then
          table.remove(possibleBranches, j)
        else
          f = possibleBranches[j]["frame"]
          i = deepcopy(possibleBranches[j]["inputs"])
          i[f] = inp --I will defer handling multi-inputs (e.g. holding B to run) to the runTest function
          
          newBranch = {
            startFrame = possibleBranches[j]["startFrame"],
            frame = f + 1,
            inputs = i
          }
          if runTest(i, subgoal["targetState"]) then
            log("Successful Inputs", 1)
            logTable(newBranch, 1)
            table.insert(viableBranches, newBranch)
          else 
            log("Not-yet-successful Inputs", 1)
            logTable(newBranch, 1)
            table.insert(possibleBranches, newBranch)
          end
          
          possibleBranches[j]["inputs"][f] = "NO_INPUT"
          possibleBranches[j]["frame"] = possibleBranches[j]["frame"] + 1
          log("possibleBranches[" .. j .. "]:", 1)
          logTable(possibleBranches[j], 1)
          --is there ever a case where I would want to test after adding a no-input?
        end
      end
    end
  end
  
  log("There are " .. table.getn(viableBranches) .. " options after subgoal " .. index)
  logTable(viableBranches, 1)
  if index ~= table.getn(subgoals) then
    possibleBranches = deepcopy(viableBranches)
    viableBranches = {}
  end
end


io.close(log_file)