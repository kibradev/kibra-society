ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function()
    ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:setJob', function(JobInfo)
    ESX.PlayerData.job = JobInfo
end)

RegisterNetEvent('esx:onPlayerDeath', function()
    ESX.PlayerData = {}
end)

Citizen.CreateThread(function()
    while true do
        local Sleep = 2000
        local PlayerPed = PlayerPedId()
        local PlayerCoord = GetEntityCoords(PlayerPed)
        for k,v in pairs(KIBRA.Societys) do
            local StashRadius = GetDistanceBetweenCoords(PlayerCoord, v.StashCoord, true)
            if StashRadius <= 2.0 then
                Sleep = 5
                for d,x in pairs(v.SocietyStashPermission) do
                    if ESX.PlayerData.job and ESX.PlayerData.job.name == x then
                        DrawText3D(v.StashCoord.x, v.StashCoord.y, v.StashCoord.z, '[E] '..v.StashText)
                        if IsControlJustReleased(0, 38) then
                            OpenStashSociety(k)
                        end
                    end
                end
            end
        end
        Citizen.Wait(Sleep)
    end
end)

function OpenStashSociety(id)
    local elements = {
		{label = "Kasaya Eşya Koy", value = 'koy'},
	}
    if KIBRA.SocietyStashGrade then
        for k,v in pairs(KIBRA.Societys[id].SocietyBossGrades) do
            if ESX.PlayerData.job and ESX.PlayerData.job.grade_name == v then
                table.insert(elements, {label = "Kasadan Eşya Al", value = 'al'})
            end
        end
    else
        table.insert(elements, {label = "Kasadan Eşya Al", value = 'al'})
    end
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'KibraDevWorks', {
		title    = KIBRA.Societys[id].SocietyName,
		align    = 'top-left',
		elements = elements
	}, function(data, menu)
		if data.current.value == 'koy' then
            PlayerInventory(id)
        elseif data.current.value == 'al' then
            KasadanEsyaAl(id)
		end
	end, function(data, menu)
		menu.close()
	end)
end

function isWeapon(item)
    if string.find(item, KIBRA.WeaponType) then
        return true
    else
        return false
    end
end

RegisterCommand('env', function()
    PlayerInventory(1)
end)

function PlayerInventory(id)
    local elements = {}
    ESX.TriggerServerCallback('Kibra:Society:Server:PlayerInventory', function(inv)
        for k,v in pairs(inv) do
            ESX.TriggerServerCallback('Kibra:Society:Server:GetByItemName', function(itemlabel)
                table.insert(elements, {label = itemlabel..' - Miktar: '..v, value = k, itemlbl = itemlabel})
                ESX.UI.Menu.CloseAll()
                ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'KibraDevWorks', {
                    title    = "Envanteriniz",
                    align    = 'top-left',
                    elements = elements
                }, function(data, menu)
                    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'karapara', 
                    {
                        title = "Koymak istediğiniz "..data.current.itemlbl..' miktarını girin'
                    }, function(data2, menu2)
                        ESX.TriggerServerCallback('Kibra:Society:Server:ItemCheck', function(item)
                            if item >= data2.value then
                                if isWeapon(data.current.value) then
                                    TriggerServerEvent('Kibra:Society:Server:PutItem', id, data.current.value, data2.value, "WEAPON", data.current.itemlbl)
                                else
                                    TriggerServerEvent('Kibra:Society:Server:PutItem', id, data.current.value, data2.value, "ITEM", data.current.itemlbl)
                                end
                            else
                                ESX.ShowNotification('Envanterinizde yeteri kadar '..data.current.itemlbl..' yok!')
                            end
                        end, data.current.value)
                        menu2.close()
                    end)
                end, function(data, menu)
                    menu.close()
                end)
            end, k)
        end 
    end)
end

function KasadanEsyaAl(id)
    local elementsx = {}
    ESX.TriggerServerCallback('Kibra:Society:Server:GetSocietyInventoryItems', function(SocietyStock)
        local New = json.decode(SocietyStock)
        for k,v in pairs(New) do
            ESX.TriggerServerCallback('Kibra:Society:Server:GetByItemName', function(item)
                table.insert(elementsx, {label = item..' - Miktar: x'..v.Count, value = v.Item, itemlbl = item, miktar = v.Count})
                ESX.UI.Menu.CloseAll()
                ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'KibraDevWorks', {
                    title    = KIBRA.Societys[id].SocietyName,
                    align    = 'top-left',
                    elements = elementsx
                }, function(data, menu)
                    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'karapara', 
                    {
                        title = "Almak istediğiniz "..data.current.itemlbl..' miktarını girin'
                    }, function(data2, menu2)
                        if data.current.miktar >= data2.value then
                            if isWeapon(data.current.value) then
                                TriggerServerEvent('Kibra:Society:Server:DepodanAl', id, data.current.value, data2.value, "WEAPON", data.current.itemlbl)
                            else
                                TriggerServerEvent('Kibra:Society:Server:DepodanAl', id, data.current.value, data2.value, "ITEM", data.current.itemlbl)
                            end
                        else
                            ESX.ShowNotification('Depoda yeteri kadar '..data.current.itemlbl..' yok!')
                        end
                        menu2.close()
                    end)
                end, function(data, menu)
                    menu.close()
                end)
            end, v.Item)
        end
    end, id)
end

DrawText3D = function (x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end