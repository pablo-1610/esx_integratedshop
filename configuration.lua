Currency = "RedBadCoins"
CurrencyShort = "RBC"

CreditsHook = "https://discord.com/api/webhooks/818160320643858473/-3jOX66JrIvpgxPf9PYMp-t_5boHxwiZOpNslgQZRSpdz78MUzjolFfLEF7U3A6BfwjU"
ShopHook = "https://discord.com/api/webhooks/818160320643858473/-3jOX66JrIvpgxPf9PYMp-t_5boHxwiZOpNslgQZRSpdz78MUzjolFfLEF7U3A6BfwjU"
NotConnectedHook = ""

Shop = {

    ["Objects"] = {
        type = "items",
        list = {
            {label = "Bière x2", price = 4500, description = nil, args = {itemID = "beer", ammount = 2}}
        }
    },

    ["Voitures"] = {
        type = "cars",
        list = {
            {label = "Rs6", price = 4500, description = nil, args = {model = "2020RS6"}},
            {label = "Mclaren 720S", price = 4500, description = nil, args = {model = "720s"}},
            {label = "991 turbo", price = 4500, description = nil, args = {model = "991 turbos"}},
            {label = "A45", price = 4500, description = nil, args = {model = "a45"}},
            {label = "Polaris", price = 4500, description = nil, args = {model = "bcrzrxp"}},
            {label = "Bugatti Bolide", price = 4500, description = nil, args = {model = "bolide"}},
            {label = "s", price = 4500, description = nil, args = {model = "sultanrs"}}
        }
    },

    ["Armes"] = {
        type = "weapons",
        list = {
            {label = "Ak47", price = 500000, description = nil, args = {hash = "weapon_assaultrifle"}}
        }
    },

    ["Argent"] = {
        type = "money",
        list = {
            {label = "250.000K$", price = 400, description = nil, args = {cash = 250000}}
        }
    }
}

Admins = {
    "license:8fc3f9bf5017c451d19593ae7d1105989d6635e0"
}