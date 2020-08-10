local t = My.Translator.translate

local StationTemplate = function()
    local station = My.SpaceStation("Large Station", "Human Navy")

    station:addTag("residual")

    return station
end

My.EventHandler:register("onWorldCreation", function()
    local hqX, hqY = vectorFromAngle(
        My.Config.avgAngle,
        My.Config.avgDistance - math.random() * My.Config.width / 2
    )
    local originX, originY = My.World.planet:getPosition()
    hqX, hqY = hqX + originX, hqY + originY
    My.World.Helper.eraseAsteroidsAround(hqX, hqY, 5000)
    local hq = StationTemplate():setPosition(hqX, hqY):
    setCallSign("SMC HQ"):
    setScannedDescription(t("station_hq_description"))

    if isFunction(hq.setRestocksScanProbes) then hq:setRestocksScanProbes(false) end

    Station:withStorageRooms(hq, {
        [products.ore] = 400,
        [products.plutoniumOre] = 40,
        [products.miningMachinery] = 100,
        [products.hvli] = 20,
        [products.homing] = 20,
        [products.mine] = 10,
        [products.emp] = 10,
        [products.nuke] = 5,
        [products.scanProbe] = 20,
    })
    hq:modifyProductStorage(products.miningMachinery, math.random(40, 80))
    hq:modifyProductStorage(products.ore, 400)
    hq:modifyProductStorage(products.hvli, math.random(0, 20))
    hq:modifyProductStorage(products.homing, math.random(0, 20))
    hq:modifyProductStorage(products.mine, math.random(0, 10))
    hq:modifyProductStorage(products.emp, math.random(0, 10))
    hq:modifyProductStorage(products.nuke, math.random(0, 1))
    hq:modifyProductStorage(products.scanProbe, math.random(4, 8))
    Station:withMerchant(hq, {
        [products.ore] = { buyingPrice = My.buyingPrice(products.ore) },
        [products.plutoniumOre] = { buyingPrice = My.buyingPrice(products.plutoniumOre) },
        [products.miningMachinery] = { sellingPrice = My.sellingPrice(products.miningMachinery) },
        [products.hvli] = { sellingPrice = My.sellingPrice(products.hvli)},
        [products.homing] = { sellingPrice = My.sellingPrice(products.homing) },
        [products.mine] = { sellingPrice = My.sellingPrice(products.mine) },
        [products.emp] = { sellingPrice = My.sellingPrice(products.emp) },
        [products.nuke] = { sellingPrice = My.sellingPrice(products.nuke) },
        [products.scanProbe] = { sellingPrice = My.sellingPrice(products.scanProbe) },
    })

    My.World.hq = hq
    table.insert(My.World.stations, hq)
    My.Database:addOrUpdateStation(hq)
end)

My.EventHandler:register("onStart", function()
    local hq = My.World.hq
    Station:withProduction(hq, {
        {
            productionTime = math.random(80, 100),
            consumes = {
                { product = products.ore, amount = 6 }
            },
            produces = {
                { product = products.homing, amount = 2 }
            }
        },{
            productionTime = math.random(55, 65),
            consumes = {
                { product = products.ore, amount = 6 }
            },
            produces = {
                { product = products.hvli, amount = 2 }
            }
        },{
            productionTime = math.random(80, 100),
            consumes = {
                { product = products.ore, amount = 6 }
            },
            produces = {
                { product = products.mine, amount = 1 }
            }
        },{
            productionTime = math.random(162, 198),
            consumes = {
                { product = products.ore, amount = 4 },
                { product = products.plutoniumOre, amount = 1 },
            },
            produces = {
                { product = products.emp, amount = 1 }
            }
        },{
            productionTime = math.random(270, 330),
            consumes = {
                { product = products.ore, amount = 6 },
                { product = products.plutoniumOre, amount = 2 },
            },
            produces = {
                { product = products.nuke, amount = 1 }
            }
        },{
            productionTime = math.random(108, 132),
            consumes = {
                { product = products.ore, amount = 40 },
            },
            produces = {
                { product = products.miningMachinery, amount = 4 }
            }
        },{
            productionTime = math.random(80,100),
            produces = {
                { product = products.miningMachinery, amount = 2 }
            }
        },{
              productionTime = math.random(108, 132),
              consumes = {
                  { product = products.ore, amount = 2 }
              },
              produces = {
                  { product = products.scanProbe, amount = 1 }
              }
          },
    })

    My.LocalBuyer(hq, products.ore, true)
    My.LocalBuyer(hq, products.plutoniumOre, true)
    My.FlyingBuyer(My.World.hq, {products.homing, products.hvli, products.mine, products.emp, products.nuke}, "Equipment")
    My.FlyingSeller(My.World.hq, {products.ore, products.plutoniumOre}, "Goods")

    Cron.regular(function(self)
        if not hq:isValid() then
            My.EventHandler:fire("onHQDestroyed")
            Cron.abort(self)
        end
    end, 1)

    My.EventHandler:register("onAttackersDetection", function()
        My.World.hq:addTag("mute")
    end)
end)

My.EventHandler:register("onStart", function()
end)
