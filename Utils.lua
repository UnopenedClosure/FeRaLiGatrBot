-------------
-- LOGGING --
-------------

function exists(file)
  local ok, err, code = os.rename(file, file)
  if not ok then
    if code == 13 then
      return true -- Permission denied, but it exists
    end
  end
  return ok, err
end

function isdir(path)
  return exists(path.."/")
end

function log(txt, level)
  level = level or 0
  io.write(string.rep("\t", level) .. tostring(txt) .. "\n")
end

function debug(txt, level)
  level = level or 0--TODO is this necessary???
  if loglevel=="DEBUG" then
    log(txt, level)
  end
end

function logTable(t, level)
  level = level or 0
  for key, value in pairs(t) do
    toPrint = string.rep("\t", level) .. key .. " = "
    if type(value) == "table" then
      log(toPrint .. "{")
      logTable(value, level + 1)
      log("\t\t}")
    else
      toPrint = toPrint .. tostring(value) .. ","
      log(toPrint)
    end
  end
end

function debugTable(t, level)
  if loglevel=="DEBUG" then
    level = level or 0--TODO is this necessary???
    logTable(t, level)
  end
end

function printTable(t, level)
  level = level or 0
  for key, value in pairs(t) do
    toPrint = string.rep("\t", level) .. key .. ":"
    if type(value) == "table" then
      print(toPrint)
      printTable(value, level + 1)
    else
      toPrint = toPrint .. tostring(value)
      print(toPrint)
    end
  end
end

function displayTimeElapsed(startTime, earlierTime)
  currentTime = os.clock()
  if earlierTime ~= nil then
    log("-- " .. string.format("Elapsed time: %.2f seconds", (currentTime - startTime)))
    local timeElapsed = earlierTime + currentTime - startTime
    log("Branches.timeElapsed = " .. timeElapsed)
  else
    print(string.format("Elapsed time: %.2f seconds", (currentTime - startTime)))
  end
end

function pairsByKeys (t, f)
  local a = {}
  for n in pairs(t) do
    table.insert(a, n)
  end
  table.sort(a, f)
  local i = 0      -- iterator variable
  local iter = function ()   -- iterator function
                 i = i + 1
                 if a[i] == nil then
                   return nil
                 else
                   return a[i], t[a[i]]
                 end
               end
  return iter
end

-------------
-- BOTTING --
-------------

function read(addr, size, bigEndianFlag)
  mem = nil
  if addr > 0xFFFF then
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
  end
  bigEndianFlag = bigEndianFlag or false--TODO isn't nil basically the same as false?????
  if size == 1 then
    return memory.read_u8(addr,mem)
  elseif bigEndianFlag then
    if size == 2 then
      return memory.read_u16_be(addr,mem)
    elseif size == 3 then
      return memory.read_u24_be(addr,mem)
    else
      return memory.read_u32_be(addr,mem)
    end
  elseif size == 2 then
    return memory.read_u16_le(addr,mem)
  elseif size == 3 then
    return memory.read_u24_le(addr,mem)
  else
    return memory.read_u32_le(addr,mem)
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

function split(inputstr, sep)
  sep=sep or ','
  local t={}
  for field, s in string.gmatch(inputstr, "([^" .. sep .. "]*)(" .. sep .. "?)") do
    table.insert(t, field)
    if s=="" then
      return t
    end
  end
end

function advanceToFrame(targetFrame)
  while emu.framecount() < targetFrame do
    emu.frameadvance()
  end
end