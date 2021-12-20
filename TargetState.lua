TargetState={}

function TargetState.direction(dir)
  return {
          register = 0x2036e50,
          numBytes = 1,
          expectedValue = Direction[dir],
         }
end

function TargetState.map(name)
  return {
          register = 0x2036dfc,
          numBytes = 4,
          expectedValue = Data.findMapValue(name),
         }
end

function TargetState.xCoord(x)
  return {
          register = 0x2036e48,
          numBytes = 2,
          expectedValue = x,
         }
end

function TargetState.yCoord(y)
  return {
          register = 0x2036e4a,
          numBytes = 2,
          expectedValue = y,
         }
end

function TargetState.spriteIsOnFoot()
  return {
              register = 0x2036e3d,
              numBytes = 1,
              expectedValue = 0,
         }
end

function TargetState.spriteIsOnBike()
  return {
              register = 0x2036e3d,
              numBytes = 1,
              expectedValue = 1,
          }
end