local object = {}

---self:edit
--- WORK IN PROGRESS
---@param
local function Edit(self)
    return self
end

--- self:remove
---
---@return nil
---@return collectgarbarge
local function Destroy(self)
    if self.entity then
        DetachEntity(self.toObj, 1, 1)
    end
    DeleteEntity(self.toObj)
    object[self.id] = nil
    return nil, collectgarbage()
end

--- object.new
---
---@param modelHash string
---@param setting table
---@return table
local function New(modelHash, setting)

    local self = {}
    local id = #object + 1

    self.id = id
    self.model = modelHash
    self.coords = setting.coords or {x = 0.0, y = 0.0, z = 0.0}
    self.rot = setting.rot or {x = 0.0, y = 0.0, z = 0.0}

    RequestModel(modelHash)

    while not HasModelLoaded(modelHash) do
        self.loaded = true
        Wait(0)
    end
    
    if setting then
        if setting.entity then
            self.entity = setting.entity
            self.bone = setting.bone
            self.entity_coords = GetOffsetFromEntityInWorldCoords(self.entity, 0.0, 0.0, 0.0)
            self.object = CreateObject(self.model, self.entity_coords[1], self.entity_coords[2], self.entity_coords[3], true, true, true)
        else
            self.object = CreateObject(self.model, self.coords[1], self.coords[2], self.coords[3], true, true, true)
        end
    end
    
    self.netId = ObjToNet(self.object)

    SetNetworkIdExistsOnAllMachines(self.netId, true)
    NetworkSetNetworkIdDynamic(self.netId, true)
    SetNetworkIdCanMigrate(self.netId, false)

    self.toObj = NetToObj(self.netId)

    if self.entity then
        AttachEntityToEntity(self.object, self.entity, GetPedBoneIndex(self.entity, self.bone), self.coords[1], self.coords[2], self.coords[3], self.rot[1], self.rot[2], self.rot[3], true, true, false, true, 1, true)
    end

    -- func ref
    self.edit = Edit
    self.remove = Destroy

    print(self.id, self.object)

    object[self.id] = self.object
    return self
end

return {
    new = New
}