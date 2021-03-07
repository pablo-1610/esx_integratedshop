local credits,shouldBeDisplayed,callback,state = nil,false,nil,0

local function digits(value)
	local left,num,right = string.match(value,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1' .. ","):reverse())..right
end

local function createTabs()
    RMenu.Add('pz_shop', 'pz_shop_main', RageUI.CreateMenu(nil, "~b~Boutique intégrée", nil, nil, "root_cause" , "shopui_title_vangelico"))
    RMenu:Get("pz_shop", "pz_shop_main").Closed = function() shouldBeDisplayed = false end
    RMenu:Get("pz_shop", "pz_shop_main").Closable = false

    RMenu.Add('pz_shop', 'pz_shop_cat', RageUI.CreateSubMenu(RMenu:Get('pz_shop', 'pz_shop_main'), nil, "~b~Boutique intégrée"))
    RMenu:Get('pz_shop', 'pz_shop_cat').Closed = function() shouldBeDisplayed = false end
    RMenu:Get("pz_shop", "pz_shop_cat").Closable = false

    RMenu.Add('pz_shop', 'pz_shop_confirm', RageUI.CreateSubMenu(RMenu:Get('pz_shop', 'pz_shop_cat'), nil, "~b~Boutique intégrée"))
    RMenu:Get('pz_shop', 'pz_shop_confirm').Closed = function() shouldBeDisplayed = false end
    RMenu:Get("pz_shop", "pz_shop_confirm").Closable = false
end

local function removeTabs()
    RMenu.Delete('pz_shop', 'pz_shop_main')
    RMenu.Delete('pz_shop', 'pz_shop_cat')
    RMenu.Delete('pz_shop', 'pz_shop_confirm')
end

local function Trim(value)
	if value then
		return (string.gsub(value, "^%s*(.-)%s*$", "%1"))
	else
		return nil
    end
end

local function getProperties(vehicle)
	local color1, color2 = GetVehicleColours(vehicle)
	local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
	local extras = {}

	for id=0, 12 do
		if DoesExtraExist(vehicle, id) then
			local state = IsVehicleExtraTurnedOn(vehicle, id) == 1
			extras[tostring(id)] = state
		end
	end

	local props = {

		model             = GetEntityModel(vehicle),

		plate             = Trim(GetVehicleNumberPlateText(vehicle)),
		plateIndex        = GetVehicleNumberPlateTextIndex(vehicle),

		health            = GetEntityHealth(vehicle),
		dirtLevel         = GetVehicleDirtLevel(vehicle),

		color1            = color1,
		color2            = color2,

		pearlescentColor  = pearlescentColor,
		wheelColor        = wheelColor,

		wheels            = GetVehicleWheelType(vehicle),
		windowTint        = GetVehicleWindowTint(vehicle),

		neonEnabled       = {
			IsVehicleNeonLightEnabled(vehicle, 0),
			IsVehicleNeonLightEnabled(vehicle, 1),
			IsVehicleNeonLightEnabled(vehicle, 2),
			IsVehicleNeonLightEnabled(vehicle, 3)
		},

		extras            = extras,

		neonColor         = table.pack(GetVehicleNeonLightsColour(vehicle)),
		tyreSmokeColor    = table.pack(GetVehicleTyreSmokeColor(vehicle)),

		modSpoilers       = GetVehicleMod(vehicle, 0),
		modFrontBumper    = GetVehicleMod(vehicle, 1),
		modRearBumper     = GetVehicleMod(vehicle, 2),
		modSideSkirt      = GetVehicleMod(vehicle, 3),
		modExhaust        = GetVehicleMod(vehicle, 4),
		modFrame          = GetVehicleMod(vehicle, 5),
		modGrille         = GetVehicleMod(vehicle, 6),
		modHood           = GetVehicleMod(vehicle, 7),
		modFender         = GetVehicleMod(vehicle, 8),
		modRightFender    = GetVehicleMod(vehicle, 9),
		modRoof           = GetVehicleMod(vehicle, 10),

		modEngine         = GetVehicleMod(vehicle, 11),
		modBrakes         = GetVehicleMod(vehicle, 12),
		modTransmission   = GetVehicleMod(vehicle, 13),
		modHorns          = GetVehicleMod(vehicle, 14),
		modSuspension     = GetVehicleMod(vehicle, 15),
		modArmor          = GetVehicleMod(vehicle, 16),

		modTurbo          = IsToggleModOn(vehicle, 18),
		modSmokeEnabled   = IsToggleModOn(vehicle, 20),
		modXenon          = IsToggleModOn(vehicle, 22),

		modFrontWheels    = GetVehicleMod(vehicle, 23),
		modBackWheels     = GetVehicleMod(vehicle, 24),

		modPlateHolder    = GetVehicleMod(vehicle, 25),
		modVanityPlate    = GetVehicleMod(vehicle, 26),
		modTrimA          = GetVehicleMod(vehicle, 27),
		modOrnaments      = GetVehicleMod(vehicle, 28),
		modDashboard      = GetVehicleMod(vehicle, 29),
		modDial           = GetVehicleMod(vehicle, 30),
		modDoorSpeaker    = GetVehicleMod(vehicle, 31),
		modSeats          = GetVehicleMod(vehicle, 32),
		modSteeringWheel  = GetVehicleMod(vehicle, 33),
		modShifterLeavers = GetVehicleMod(vehicle, 34),
		modAPlate         = GetVehicleMod(vehicle, 35),
		modSpeakers       = GetVehicleMod(vehicle, 36),
		modTrunk          = GetVehicleMod(vehicle, 37),
		modHydrolic       = GetVehicleMod(vehicle, 38),
		modEngineBlock    = GetVehicleMod(vehicle, 39),
		modAirFilter      = GetVehicleMod(vehicle, 40),
		modStruts         = GetVehicleMod(vehicle, 41),
		modArchCover      = GetVehicleMod(vehicle, 42),
		modAerials        = GetVehicleMod(vehicle, 43),
		modTrimB          = GetVehicleMod(vehicle, 44),
		modTank           = GetVehicleMod(vehicle, 45),
		modWindows        = GetVehicleMod(vehicle, 46),
		modLivery         = GetVehicleLivery(vehicle),
		windowStatus = {},
		tyres = {},
		
	}

	if vehicle ~= nil then
		if not AreAllVehicleWindowsIntact(vehicle) then
			for i = 1,6 do
				print(IsVehicleWindowIntact(vehicle, i))
				props.windowStatus[i] = IsVehicleWindowIntact(vehicle, i)
			end
		end

		for i = 0, 5 do
			props.tyres[i] = IsVehicleTyreBurst(vehicle, i, true)
		end
	end

	return props
end

local function createMenu()
    if shouldBeDisplayed then return end shouldBeDisplayed = true
    state = 0
    local colorVariator,selectedCat,selectedOffer,colorWarning,point = "~y~",nil,nil,"~s~",""
    createTabs()
    RageUI.Visible(RMenu:Get("pz_shop", "pz_shop_main"), true)

    Citizen.CreateThread(function()
        while shouldBeDisplayed do Wait(750)
            if colorVariator == "~y~" then colorVariator = "~o~" else colorVariator = "~y~" end
            if colorWarning == "~s~" then colorWarning = "~r~" else colorWarning = "~s~" end
            if point == "" then point = "." elseif point == "." then point = ".." elseif point == ".." then point = "..." elseif point == "..." then point = "" end
        end
    end)

    Citizen.SetTimeout(150, function() TriggerServerEvent("pz_integratedshop:requestAccount") end)

    while shouldBeDisplayed do
        local requireClose = true

        RageUI.IsVisible(RMenu:Get("pz_shop", "pz_shop_confirm"),true,true,true,function()
            requireClose = false
            if state == 0 then
                RageUI.Separator(colorVariator.."Confirmer l'achat ~b~\""..selectedOffer.infos.label.."\""..colorVariator.." pour ~g~"..digits(selectedOffer.infos.price).." "..CurrencyShort)
                if not (credits >= selectedOffer.infos.price) then RageUI.Separator(colorWarning.."Vous n'avez pas assez de "..Currency.." !") end
                RageUI.Separator("~s~↓ ~g~Actions ~s~↓")
                RageUI.ButtonWithStyle("~r~Anuler ~s~→→",nil, {}, true, function(_,_,s) if s then 
                    RageUI.GoBack()
                end end)
                RageUI.ButtonWithStyle("~g~Confirmer l'achat ~s~→→",nil, {}, credits >= selectedOffer.infos.price, function(_,_,s) if s then 
                    state = 1
                    if Shop[selectedCat].type == "cars" then 
                        Citizen.CreateThread(function()
                            local properties = {}
                            local thisMod = GetHashKey(selectedOffer.infos.args.model)
                            local co = GetEntityCoords(PlayerPedId())
                            RequestModel(thisMod)
                            while not HasModelLoaded(thisMod) do Wait(1) end
                            local veh = CreateVehicle(thisMod, co, 90.0, false, false)
                            while veh == nil do Wait(1) end
                            properties = getProperties(veh)
                            if veh ~= nil then DeleteEntity(veh) end
                            TriggerServerEvent("pz_integratedshop:sendPurchaseRequest", selectedCat, selectedOffer, {mods = properties})
                        end)
                    elseif Shop[selectedCat].type == "weapons" then 
                        TriggerServerEvent("pz_integratedshop:sendPurchaseRequest", selectedCat, selectedOffer, {hash = selectedOffer.infos.args.hash})
                    elseif Shop[selectedCat].type == "money" then
                        TriggerServerEvent("pz_integratedshop:sendPurchaseRequest", selectedCat, selectedOffer, {money = selectedOffer.infos.args.cash})
                    elseif Shop[selectedCat].type == "items" then
                        TriggerServerEvent("pz_integratedshop:sendPurchaseRequest", selectedCat, selectedOffer, {ammount = selectedOffer.infos.args.ammount, item = selectedOffer.infos.args.itemID})
                    else
                        TriggerServerEvent("pz_integratedshop:sendPurchaseRequest", selectedCat, selectedOffer, {}) -- TODO ACHAT
                    end
                end end)
            elseif state == 1 then
                RageUI.Separator("")
                RageUI.Separator(colorVariator.."Transaction avec le serveur en cours"..point)
                RageUI.Separator("")
            else
                RageUI.Separator("~b~Réponse du serveur:")
                RageUI.Separator("")
                callback()
                RageUI.Separator("")
                RageUI.ButtonWithStyle("~r~Retour ~s~→→",nil, {}, true, function(_,_,s) if s then 
                    state = 0
                    callback = nil
                end end)
            end
        end, function()    
        end, 1)

        RageUI.IsVisible(RMenu:Get("pz_shop", "pz_shop_cat"),true,true,true,function()
            requireClose = false
            RageUI.Separator(colorVariator.."Catégorie actuelle: ~b~"..selectedCat)
            RageUI.Separator(colorVariator.."Vous avez: ~b~"..credits..colorVariator.." "..Currency)
            RageUI.Separator("")
            RageUI.Separator("~s~↓ ~g~Actions ~s~↓")
            RageUI.ButtonWithStyle("~r~Retour ~s~→→",nil, {}, true, function(_,_,s) if s then 
                RageUI.GoBack()
            end end)
            RageUI.Separator("~s~↓ ~b~Offres ~s~↓")
            for pos,data in pairs(Shop[selectedCat].list) do
                RageUI.ButtonWithStyle("~b~"..data.label,data.description, {RightLabel = "~g~"..digits(data.price).." "..CurrencyShort.." ~s~→→"}, true, function(_,_,s) if s then 
                    selectedOffer = {infos = data, id = pos}
                end end, RMenu:Get("pz_shop", "pz_shop_confirm"))
            end
        end, function()    
        end, 1)

        RageUI.IsVisible(RMenu:Get("pz_shop", "pz_shop_main"),true,true,true,function()
            requireClose = false
            if not credits then
                RageUI.Separator("")
                RageUI.Separator("~o~Un instant, nous récupérons vos données...")
                RageUI.Separator("")
            else
                RageUI.Separator(colorVariator.."Bienvenue sur la boutique, "..GetPlayerName(PlayerId()).." !")
                RageUI.Separator(colorVariator.."Vous avez: ~b~"..credits..colorVariator.." "..Currency)
                RageUI.Separator("")
                RageUI.Separator("~s~↓ ~g~Actions ~s~↓")
                RageUI.ButtonWithStyle("~r~Fermer le menu ~s~→→","Fermez la boutique et retournez au jeu.", {}, true, function(_,_,s) if s then 
                   requireClose = true
                   selectedOffer = nil
                   credits = nil
                   selectedCat = nil
                   RageUI.CloseAll()
                end end)
                RageUI.Separator("~s~↓ ~b~Catégories ~s~↓")
                for label,data in pairs(Shop) do
                    RageUI.ButtonWithStyle("~b~Catégorie "..colorVariator.."\""..label.."\"~s~","Accédez à la catégorie "..label, {RightLabel = "~o~Consulter la catégorie ~s~→"}, true, function(_,_,s) if s then 
                        selectedCat = label
                    end end, RMenu:Get("pz_shop", "pz_shop_cat"))
                end
            end
        end, function()    
        end, 1)
        if requireClose then shouldBeDisplayed = false credits = nil selectedCat = nil state = nil callback = nil end
        Wait(0)
    end
end

Citizen.CreateThread(function()
    while true do Wait(1)
        if IsControlJustPressed(1, 57) then 
            createMenu() 
        end
    end
end)

RegisterNetEvent("pz_integratedshop:callbackAccount")
AddEventHandler("pz_integratedshop:callbackAccount", function(int) credits = int end)

local function getStateByIndex(int)
    local err = {
        [1] = function() RageUI.Separator("~g~Achat effectué ! Profitez bien !") end,
        [2] = function() RageUI.Separator("~r~Vous n'avez pas assez de "..Currency) end,
        [3] = function() RageUI.Separator("~r~Une erreur interne est survenue :(") end
    }
    return err[int]
end

RegisterNetEvent("pz_integratedshop:callbackPurchase")
AddEventHandler("pz_integratedshop:callbackPurchase", function(toRespond, args)
    state = 2
    callback = getStateByIndex(toRespond)
    if args.weapon ~= nil then
        print("OK WEAPONS")
        GiveWeaponToPed(PlayerPedId(), GetHashKey(args.weapon), 10000, false, true)
    end
end)
