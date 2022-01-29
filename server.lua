ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('Kibra:Society:Server:PlayerInventory', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source) 
    local PlayerInventory = xPlayer.getInventory(true)
    cb(PlayerInventory)
end)

ESX.RegisterServerCallback('Kibra:Society:Server:GetByItemName', function(source, cb, item)
    cb(ESX.GetItemLabel(item))
end)

RegisterNetEvent('Kibra:Society:Server:PutItem', function(id, item, count, itemtype, itemlabel)
    local src = source
    local Player = ESX.GetPlayerFromId(src)
    local ItemData = MySQL.Sync.fetchAll('SELECT * FROM kibra_society WHERE id = @id', {["@id"] = id})
    if itemtype == "WEAPON" then
        if #ItemData[1].weapons > 0 then
            local GetItems = json.decode(ItemData[1].weapons)
            for k,v in pairs(GetItems) do
                datadakimiktar = tonumber(v.Count)
                local GuncelTablo = {{Item = item, Count = datadakimiktar+count}}
                MySQL.Async.fetchAll('UPDATE kibra_society set weapons = @Items WHERE id = @id', {
                    ['@Items'] = json.encode(GuncelTablo),
                    ["@id"] = id
                })
            end
        else
            local Items = {
                {Item = item, Count = count}
            }
            local ItemsGuncel = json.encode(Items)
            MySQL.Async.fetchAll('UPDATE kibra_society set weapons = @Items WHERE id = @id', {
                ['@Items'] = ItemsGuncel,
                ["@id"] = id
            })
        end
        Player.removeInventoryItem(item, count)
        TriggerClientEvent('esx:showNotification', src, 'Başarıyla '..KIBRA.Societys[id].SocietyName..' deposuna '..count..' tane '..itemlabel..' koydunuz!')
    else
        if #ItemData[1].items > 0 then
            local GetItems = json.decode(ItemData[1].items)
            for k,v in pairs(GetItems) do
                datadakimiktar = tonumber(v.Count)
                local GuncelTablo = { {Item = item, Count = datadakimiktar+count}}
                MySQL.Async.fetchAll('UPDATE kibra_society set items = @Items WHERE id = @id', {
                    ['@Items'] = json.encode(GuncelTablo),
                    ["@id"] = id
                })
            end
        else
            local Items = {
                {Item = item, Count = count}
            }
            local ItemsGuncel = json.encode(Items)
            MySQL.Async.fetchAll('UPDATE kibra_society set items = @Items WHERE id = @id', {
                ['@Items'] = ItemsGuncel,
                ["@id"] = id
            })
        end
        Player.removeInventoryItem(item, count)
        TriggerClientEvent('esx:showNotification', src, 'Başarıyla '..KIBRA.Societys[id].SocietyName..' deposuna '..count..' tane '..itemlabel..' koydunuz!')
    end
end)

RegisterCommand('checkjob', function(source)
    local Player = ESX.GetPlayerFromId(source)
    local PlayerJob = "Your Job: "..Player.job.name..' || Grade: '..Player.job.grade_name 
    TriggerClientEvent('esx:showNotification', source, PlayerJob)
end)

RegisterNetEvent('Kibra:Society:Server:DepodanAl', function(id, item, count, type, itemlbl)
    local src = source
    local Player = ESX.GetPlayerFromId(src)
    local Data = MySQL.Sync.fetchAll('SELECT * FROM kibra_society WHERE id = @id', {["@id"] = id})
    if type == "WEAPON" then
        if #Data[1].weapons > 0 then
            local GetItems = json.decode(Data[1].weapons)
            for k,v in pairs(GetItems) do
                datadakimiktarx = tonumber(v.Count)
                local GuncelTablo = {{Item = item, Count = datadakimiktarx-count}}
                MySQL.Async.fetchAll('UPDATE kibra_society set weapons = @Items WHERE id = @id', {
                    ['@Items'] = json.encode(GuncelTablo),
                    ["@id"] = id
                })
            end
            Player.addInventoryItem(item, count)
            TriggerClientEvent('esx:showNotification', src, KIBRA.Societys[id].SocietyName..' deposundan '..count..' tane '..itemlbl..' aldınız!')
        end
    else
        if #Data[1].items > 0 then
            local GetItems = json.decode(Data[1].items)
            for k,v in pairs(GetItems) do
                datadakimiktarf = tonumber(v.Count)
                local GuncelTablo = { {Item = item, Count = datadakimiktarf-count}}
                MySQL.Async.fetchAll('UPDATE kibra_society set items = @Items WHERE id = @id', {
                    ['@Items'] = json.encode(GuncelTablo),
                    ["@id"] = id
                })
            end
            Player.addInventoryItem(item, count)
            TriggerClientEvent('esx:showNotification', src, KIBRA.Societys[id].SocietyName..' deposundan '..count..' tane '..itemlbl..' aldınız!')
        end
    end
end)

ESX.RegisterServerCallback('Kibra:Society:Server:GetSocietyInventoryItems', function(source, cb,id)
    local SocietyInventory = MySQL.Sync.fetchAll('SELECT * FROM kibra_society WHERE id = @id', {["@id"] = id})
    if #SocietyInventory > 0 then
        cb(SocietyInventory[1].items)
    end
end)

ESX.RegisterServerCallback('Kibra:Society:Server:ItemCheck', function(source, cb, item)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return; end
    local items = xPlayer.getInventoryItem(item)
    if items == nil then
        cb(0)
    else
        cb(items.count)
    end
end)
