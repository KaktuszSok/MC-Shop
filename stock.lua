local config = peripheral.wrap("back") --template
local target = peripheral.wrap("bottom") --subject
local source = peripheral.wrap("top") --supply

--Does item b have the same ID and NBT as item a?
function ItemsMatch(a, b)
    if b == nil and a == nil then return true end --Match if both are nil
    if b == nil then return false end
    if b.name ~= a.name then return false end
    if b.nbt ~= a.nbt then return false end
    return true
end

--Try to make slot in target chest match config
function SupplementSlot(slot)
    local configItem = config.getItemMeta(slot) --Item based on template
    if configItem == nil then print("invalid slot") return end
    local targetCount = configItem.count --Count based on template
    local currCount = 0
    if target.getItemMeta(slot) ~= nil then
        currCount = target.getItemMeta(slot).count --Get the count
    end
    
    --Make sure slot has correct item
    if not ItemsMatch(configItem, target.getItemMeta(slot)) then
        target.drop(slot)
        currCount = 0
    end
    
    --Look through all the supply slots and supplement
    for k,v in pairs(source.list()) do
        if ItemsMatch(configItem, v) then
            local maxAmt = targetCount - currCount
            --Keep minimum of 1 in stock in supply chest:
            maxAmt = math.min(v.count - 1, maxAmt)
            
            if maxAmt > 0 then
                source.pushItems("bottom", k, maxAmt, slot)
            end
            
            --Update currCount
            if target.getItemMeta(slot) ~= nil then
                currCount = target.getItemMeta(slot).count
            else
                currCount = 0
            end 
            --Stop if achieved sufficient supply
            if currCount >= targetCount then return end
        end
    end
end

function CompareChests()
    local configInv = config.list()
    configInv[27] = nil --Ignore price slot
    
    for k,v in pairs(configInv) do
          local t = target.list()[k]
          if not ItemsMatch(v, t) then return false end
          if t.count < v.count then return false end
    end
    
    return true
end

function SupplementAll()
    local configInv = config.list()
    configInv[27] = nil

    for k,v in pairs(configInv) do
        SupplementSlot(k)
    end
end

--Main Loop
function Main()
    while true do
        if not CompareChests() then
            SupplementAll()
        end
        sleep(1.25)    
    end
end

Main()
