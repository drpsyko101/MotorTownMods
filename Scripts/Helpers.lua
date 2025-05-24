---Convert FVector to string
---@param vector FVector
function VectorToString(vector)
  return string.format('{"X":%.3f,"Y":%.3f,"Z":%.3f}', vector.X, vector.Y, vector.Z)
end

---Convert FGuid to string
---@param guid FGuid
function GuidToString(guid)
  return string.format("%x%x%x%x", guid.A, guid.B, guid.C, guid.D)
end
