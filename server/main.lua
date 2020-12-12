local accounts = {}
local prefix = "^1[Shop] ^7"

local function trace(str)
    print(prefix..str.."^7")
end

local function hasAccount(targetLicense)
    return accounts[targetLicense] ~= nil
end

local function getDate()
    return os.date("*t", os.time()).day.."/"..os.date("*t", os.time()).month.."/"..os.date("*t", os.time()).year.." à "..os.date("*t", os.time()).hour.."h"..os.date("*t", os.time()).min
end

local function canPurchase(targetLicense, ammount)
    if not hasAccount(targetLicense) then return end
    return (accounts[targetLicense] - ammount) >= 0
end

local function getAccount(targetLicense)
    if hasAccount(targetLicense) then
        return accounts[targetLicense]
    else
        return 0
    end
end

local function initializeCache()
    accounts = {}
    local saved = 0
    MySQL.Async.fetchAll('SELECT * FROM credits', {}, function(result) for id,data in pairs(result) do 
        accounts[data.license] = data.credits 
        saved = saved + 1
    end trace(saved.." entrées dans les "..Currency.." importées et sauvegardées") end)
end

local function getLicense(source)
    local license  = false
	for k,v in pairs(GetPlayerIdentifiers(source))do
		if string.sub(v, 1, string.len("license:")) == "license:" then
			license = v
        end
	end
	return license
end

local function getSteam(source)
    local steam  = false
	for k,v in pairs(GetPlayerIdentifiers(source))do
		if string.sub(v, 1, string.len("steam:")) == "steam:" then
			steam = v
        end
	end
	return steam
end

local function addCredits(targetLicense, ammount)
    if ammount <= 0 then return end
    if not hasAccount(targetLicense) then
        accounts[targetLicense] = ammount
         
        MySQL.Async.execute('INSERT INTO credits (license,credits,lastUpdate) VALUES (@a,@b,@c)',{['a'] = targetLicense,['b'] = ammount,['c'] = getDate()},
        function(affectedRows) trace("Ajout de ^3"..ammount.." "..Currency.." ^7sur la license ^3"..targetLicense) end)
    else
        accounts[targetLicense] = accounts[targetLicense] + ammount
        MySQL.Async.execute('UPDATE credits SET credits = @a, lastUpdate = @b WHERE license = @c',{['a'] = accounts[targetLicense],['b'] = getDate(),['c'] = targetLicense},
        function(affectedRows) trace("Ajout de ^3"..ammount.." "..Currency.." ^7sur la license ^3"..targetLicense) end)
    end
end

local function rmvCredits(targetLicense, ammount)
    if ammount <= 0 then return end
    if not hasAccount(targetLicense) then
        trace("Tentative de supprimer des impulsioncoins à une entrée non valide: ^3"..targetLicense)
        return
    end 
    if (accounts[targetLicense] - ammount) <= 0 then return end
    accounts[targetLicense] = accounts[targetLicense] - ammount
    MySQL.Async.execute('UPDATE credits SET credits = @a, lastUpdate = @b WHERE license = @c',{['a'] = accounts[targetLicense],['b'] = getDate(),['c'] = targetLicense},
    function(affectedRows) trace("Retrait de ^3"..ammount.." "..Currency.." ^7sur la license ^3"..targetLicense) end)
end

local function sendToDiscord(name,message,color,url)
    local DiscordWebHook = url
    local embeds = {
        {
            ["title"]=message,
            ["type"]="rich",
            ["color"] =color,
            ["footer"]=  {
            ["text"]= Currency,
            },
        }
    }
    if message == nil or message == '' then return FALSE end
    PerformHttpRequest(DiscordWebHook, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })
end

Citizen.CreateThread(function() initializeCache() end)

RegisterNetEvent("pz_integratedshop:requestAccount")
AddEventHandler("pz_integratedshop:requestAccount", function()
    local _src = source
    local license = getLicense(_src)
    local credits = getAccount(license)
    TriggerClientEvent("pz_integratedshop:callbackAccount", _src, credits)
end)

RegisterNetEvent("pz_integratedshop:sendPurchaseRequest")
AddEventHandler("pz_integratedshop:sendPurchaseRequest", function(category, offer, args)
    local _src = source
    local license = getLicense(_src)
    local credits = getAccount(license)
    if not Shop[category] or not Shop[category].list[offer.id] then return end -- Anti Cheat
    if credits < offer.infos.price then
        TriggerClientEvent("pz_integratedshop:callbackPurchase", _src, 2, {})
        return
    end
    rmvCredits(license,offer.infos.price)
    TriggerClientEvent("pz_integratedshop:callbackAccount", _src, getAccount(license))

    if Shop[category].type == "cars" then
        if not args.mods then
            TriggerClientEvent("pz_integratedshop:callbackPurchase", _src, 3, {})
            return
        end
        local steam = getSteam(_src)
        MySQL.Async.execute('INSERT INTO owned_vehicles (owner,plate,vehicle,type,job,stored) VALUES (@a,@b,@c,@d,@e,@f)',{['a'] = steam, ['b'] = args.mods.plate, ['c'] = json.encode(args.mods), ['d'] = "car", ['e'] = "", ['f'] = 1},
        function(affectedRows) TriggerClientEvent("pz_integratedshop:callbackPurchase", _src, 1, {}) end)
    end

    if Shop[category].type == "weapons" then
        if not args.hash then
            TriggerClientEvent("pz_integratedshop:callbackPurchase", _src, 3, {})
            return
        end
        TriggerClientEvent("pz_integratedshop:callbackPurchase", _src, 1, {weapon = args.hash})
    end

    if Shop[category].type == "money" then
        if not args.money then
            TriggerClientEvent("pz_integratedshop:callbackPurchase", _src, 3, {})
            return
        end
        TriggerClientEvent("pz_integratedshop:callbackPurchase", _src, 1, {})
    end

    trace(GetPlayerName(_src).." a acheté ^3\""..offer.infos.label.."\"^7 pour la somme de ^3"..offer.infos.price.." "..Currency.." ^7!")
    sendToDiscord("Logs shop IG", "Le joueur **"..GetPlayerName(_src).."** a acheté **"..offer.infos.label.."** pour la somme de __"..offer.infos.price.."__ "..Currency,56108,ShopHook)
end)

RegisterCommand("credit", function(source, args, rawCommand)
    local source = source
    if source == 0 then
        if args[1] == nil or args[2] == nil then return end
        local ammount = tonumber(args[2])
        local license = tostring(args[1])
        sendToDiscord("Logs crédits", "Ajout de **"..ammount.."** "..Currency.." sur la license __"..license.."__", 56108,CreditsHook)
        addCredits(license,ammount)
    else
        if args[1] == nil or args[2] == nil or args[3] == nil then return end
        local license = getLicense(source)
        local can = false
        for _,allowed in pairs(Admins) do if allowed == license then can = true end end
        if not can then 
            trace(GetPlayerName(source).." a essayé d'executer la commande crédit sans permissions ! ["..license.."]")
            return 
        end
        local target = tonumber(args[1])
        local targetPlayer = ESX.GetPlayerFromId(target)
        if targetPlayer then
            local destLicense = getLicense(targetPlayer.source)
            if args[2]:lower() == "add" then
                local ammount = tonumber(args[3])
                addCredits(destLicense,ammount)
                sendToDiscord("Logs crédits [ADMIN]", "[ADMIN] L'admin **"..GetPlayerName(source).."** ["..license.."] a donné "..ammount.." "..Currency.." à **"..GetPlayerName(targetPlayer.source).."**", 56108,CreditsHook)
            elseif args[2]:lower() == "rmv" then
                local ammount = tonumber(args[3])
                rmvCredits(destLicense,ammount)
                sendToDiscord("Logs crédits [ADMIN]", "[ADMIN] L'admin **"..GetPlayerName(source).."** ["..license.."] a retiré "..ammount.." "..Currency.." à **"..GetPlayerName(targetPlayer.source).."**", 56108,CreditsHook)
            end
        end
    end
end, false)