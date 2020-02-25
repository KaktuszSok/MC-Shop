local chest = peripheral.wrap("right") --Transaction chest (EChest)
local config = peripheral.wrap("top") --Configuration chest
local supply = peripheral.wrap("back") --Supply chest
--Left: Pay Output

local function ReadBuyButton()
    return redstone.getInput("front") --WiFi redstone
end

local function IsPaymentEnough(paystack, price)
    --Make sure item type is right
    if(paystack == nil) then return false end
    local payMeta = paystack.getMetadata()
    if(payMeta.name ~= config.getItemMeta(27).name)
    then return false end
    
    --Return whether payment is enough
    return payMeta.count >= price
end

local function CheckEChestHasSpace(itemList)
    local numSlotsNeeded = table.getn(itemList)
    local slotsFree = 27 - table.getn(chest.list())
    return slotsFree > numSlotsNeeded
end

local function CheckItemsInStock(itemList)
    for k, v in pairs(itemList) do --For each itemstack to be sold
        --Match item in supply
        local supplyMatch = supply.getItem(k)
        if supplyMatch == nil then return false end
        --Compare count
        local matchMeta = supplyMatch.getMetadata()
        if matchMeta.count < v.count then
            return false end
     end
    
    --If all checks passed, we are in stock
    return true
end


local function OnBuyPressed()
    --Generate list of items to sell
    local sellList = config.list()
    sellList[27] = nil

    --Check if EChest has space
    if not CheckEChestHasSpace(sellList) then
        print("\nno space in enderchest")
        return
    end

    --Check if items are in stock
    if not CheckItemsInStock(sellList) then
        print("\nitems out of stock")
        return
    end    
    
    --Set price to 27th slot's count
    local priceMeta = config.getItemMeta(27)
    if priceMeta == nil then
        print("\ninvalid config chest configuration")
        return
    end
    local price = priceMeta.count
    
    --Check if payment meets price
    local payment = chest.getItem(27)
    if not IsPaymentEnough(payment, price) then
        print("\npayment does not meet price")
        return
    end
    
    --Transaction
    local funds = payment.getMetadata().count --How many diamonds in pay slot?
    print("\nprocessing transaction...")
    print("price: " .. price)
    print("funds: " .. funds)
    print("remaining: " .. (funds - price))
        --Pull payment
    chest.pushItems("left", 27, price)
        --Push items
    for i=1,26 do
        local maxAmt = 0
        if sellList[i] ~= nil and sellList[i].count ~= nil then
            maxAmt = sellList[i].count
        end
        if maxAmt > 0 then
            chest.pullItems("back", i, maxAmt)
        end
    end
    print("transaction successful!")
end


--Main Loop
local function Main()
    local buyWasPressed = false
    while true do
        --Buy button to pulse
        buyPressed = ReadBuyButton()
        buyNow = (buyPressed and not buyWasPressed)
        if buyNow then OnBuyPressed() end    
        
        --Loop logic
        buyWasPressed = buyPressed
        sleep(0)
    end
end

Main()
