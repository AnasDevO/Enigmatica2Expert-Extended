import crafttweaker.data.IData;
import crafttweaker.item.IItemStack;
import crafttweaker.player.IPlayer;
import mods.ctintegration.data.DataUtil.parse as sNBT;
import crafttweaker.block.IBlock;
import crafttweaker.world.IWorld;

#priority 3999
#loader crafttweaker reloadableevents

utils.DEBUG = true;

function giveChest(player as IPlayer, items as IItemStack[]) as void {
  var tag = {
    BCTileData: {
      Items: []
    },
  } as IData;
  for i, item in items {
    tag = tag + {BCTileData: {Items: [item as IData + {Slot: i as short} as IData]}} as IData;
  }
  player.give(<draconicevolution:draconium_chest>.withTag(tag));
}

function dumpLightSources(player as IPlayer) as void {
  for light in 13 .. 16 {
    var items = [] as IItemStack[];
    var ids = [] as string[];
    for i,block in game.blocks {
      val ll = block.lightLevel;
      if(ll <= 0) continue;
      utils.log(ll, block.id);

      if(ll == light) {
        ids += block.id;
      }
    }
    mods.ctintegration.util.ArrayUtil.sort(ids);
    for id in ids {
      val item = itemUtils.getItem(id);
      if(!isNull(item)) items += item;
      else utils.log('Light without item:', id);
    }
    giveChest(player, items);
  }
}

function dumpAllOldRewards(player as IPlayer) as void {
  giveChest(player, [
    <bhc:red_heart>,
    <biomesoplenty:sapling_0:4>,
    <biomesoplenty:sapling_1:1>,
    <biomesoplenty:sapling_1:7>,
    <biomesoplenty:sapling_1>,
    <biomesoplenty:terrarium:13> * 2,
    <botania:elfglasspane> * 64,
    <chisel:block_coal_coke1:12> * 4,
    <chisel:bookshelf_oak> * 8,
    <chisel:chisel_hitech>,
    <chisel:futura:2>,
    <chisel:ice:7> * 64,
    <chisel:icepillar:4> * 64,
    <chisel:icepillar:5> * 64,
    <chisel:obsidian:13> * 64,
    <chisel:prismarine:6> * 64,
    <chisel:redstone1:8> * 8,
    <cyclicmagic:beacon_redstone> * 2,
    <cyclicmagic:sleeping_mat>,
    <darkutils:trap_tile:2> * 16,
    <extrautils2:decorativeglass:1> * 64,
    <extrautils2:decorativeglass:4> * 64,
    <extrautils2:decorativeglass:5> * 64,
    <forestry:doors.cocobolo> * 4,
    <forestry:doors.giganteum> * 4,
    <forestry:doors.mahoe> * 4,
    <forestry:doors.walnut> * 4,
    <forestry:doors.wenge> * 4,
    <harvestcraft:apricotjellysandwichitem> * 8,
    <harvestcraft:avocado_sapling>,
    <harvestcraft:cashew_sapling>,
    <harvestcraft:cheddarandsourcreampotatochipsitem> * 8,
    <harvestcraft:chickencelerycasseroleitem> * 8,
    <harvestcraft:cranberryjellysandwichitem> * 8,
    <harvestcraft:dragonfruit_sapling>,
    <harvestcraft:extremechiliitem> * 8,
    <harvestcraft:fishsandwichitem> * 8,
    <harvestcraft:garlicchickenitem> * 8,
    <harvestcraft:gingerchickenitem> * 8,
    <harvestcraft:icecreamitem> * 8,
    <harvestcraft:limejellysandwichitem> * 8,
    <harvestcraft:mintchocolatechipicecreamitem> * 8,
    <harvestcraft:nutellaitem> * 8,
    <harvestcraft:pemmicanitem> * 8,
    <harvestcraft:pineapplehamitem> * 8,
    <harvestcraft:redvelvetcakeitem> * 8,
    <harvestcraft:spagettiandmeatballsitem> * 8,
    <harvestcraft:sweetandsourmeatballsitem> * 8,
    <harvestcraft:well>,
    <harvestcraft:zestyzucchiniitem> * 8,
    <immersiveengineering:metal_decoration2:4> * 16,
    <immersiveengineering:metal_device1:9> * 8,
    <mekanism:balloon:2> * 16,
    <minecraft:banner:6> * 16,
    <minecraft:bone_block> * 24,
    <minecraft:bookshelf> * 4,
    <minecraft:cactus> * 16,
    <minecraft:chorus_flower> * 2,
    <minecraft:clay> * 16,
    <minecraft:deadbush> * 64,
    <minecraft:dirt:2>,
    <minecraft:end_bricks> * 32,
    <minecraft:end_rod> * 8,
    <minecraft:grass> * 16,
    <minecraft:hay_block> * 9,
    <minecraft:lit_pumpkin>,
    <minecraft:mossy_cobblestone> * 32,
    <minecraft:mycelium> * 16,
    <minecraft:nether_wart_block> * 2,
    <minecraft:painting> * 3,
    <minecraft:prismarine> * 32,
    <minecraft:red_flower:3> * 8,
    <minecraft:sea_lantern> * 8,
    <minecraft:slime> * 4,
    <minecraft:soul_sand> * 64,
    <minecraft:sponge> * 4,
    <minecraft:waterlily> * 16,
    <minecraft:web> * 4,
    <openblocks:beartrap> * 3,
    <openblocks:beartrap> * 8,
    <openblocks:dev_null>,
    <openblocks:fan> * 4,
    <openblocks:golden_egg>,
    <openblocks:luggage>,
    <openblocks:sponge_on_a_stick>,
    <openblocks:target> * 8,
    <opencomputers:storage:1>,
    <quark:lit_lamp> * 16,
    <quark:obsidian_pressure_plate> * 4,
    <quark:smoker> * 4,
    <quark:soul_bead>,
    <rats:assorted_vegetables> * 16,
    <rats:cheese> * 8,
    <rats:garbage_pile> * 6,
    <rats:garbage_pile> * 8,
    <rats:plastic_waste> * 16,
    <rats:rat_burger> * 8,
    <rats:rat_crafting_table>,
    <rats:rat_lantern> * 4,
    <rats:rat_pelt> * 8,
    <rats:rat_tube_light_blue> * 8,
    <rats:raw_rat> * 16,
    <rustic:candle> * 16,
    <rustic:chair_ironwood> * 8,
    <rustic:chandelier> * 2,
    <rustic:iron_lantern> * 16,
    <rustic:table_ironwood> * 8,
    <rustic:vase> * 8,
    <scalingfeast:heartyshank>,
    <storagedrawers:compdrawers> * 2,
    <storagedrawers:framingtable>,
    <storagedrawers:tape>,
    <tconstruct:ingots:4> * 8,
    <tconstruct:materials:13>,
    <tconstruct:seared_tank:1> * 4,
    <tconstruct:seared:6> * 24,
    <tconstruct:slime_congealed:3> * 64,
    <tconstruct:slime_grass_tall:4> * 16,
    <tconstruct:slimesling>,
    <tconstruct:soil:4> * 64,
    <tconstruct:throwball:1> * 16,
    <tconstruct:throwball> * 16,
    <tconstruct:tooltables:5>,
    <thaumcraft:loot_bag> * 5,
    <thermaldynamics:duct_64> * 128,
    <thermalexpansion:florb:1>.withTag(sNBT('{Fluid:"bio.ethanol"}')) * 10,
    <thermalexpansion:florb:1>.withTag(sNBT('{Fluid:"lava"}')) * 4,
    <thermalexpansion:florb:1>.withTag(sNBT('{Fluid:"syngas"}')) * 10,
    <thermalexpansion:florb>.withTag(sNBT('{Fluid:"water"}')) * 64,
    <thermalexpansion:morb>.withTag(sNBT('{Generic:1b,id:"minecraft:chicken"}')) * 2,
    <thermalexpansion:morb>.withTag(sNBT('{Generic:1b,id:"minecraft:cow"}')) * 2,
    <thermalexpansion:morb>.withTag(sNBT('{Generic:1b,id:"minecraft:llama"}')) * 2,
    <thermalexpansion:morb>.withTag(sNBT('{Generic:1b,id:"minecraft:pig"}')) * 2,
    <thermalexpansion:morb>.withTag(sNBT('{Generic:1b,id:"minecraft:rabbit"}')) * 2,
    <thermalexpansion:morb>.withTag(sNBT('{Generic:1b,id:"minecraft:sheep"}')) * 2,
    <thermalexpansion:morb>.withTag(sNBT('{Generic:1b,id:"quark:crab"}')) * 2,
    <thermalexpansion:morb>.withTag(sNBT('{Generic:1b,id:"quark:frog"}')) * 2,
    <thermalfoundation:ore:5> * 16,
    <thermalfoundation:storage_alloy:1>,
    <thermalfoundation:storage_alloy:4>,
    <thermalfoundation:tool.shield_diamond>,
    <twilightforest:twilight_sapling:1>,
    <twilightforest:twilight_sapling:9>,
  ]);


  giveChest(player, [
    <actuallyadditions:item_coffee>,
    <advancedrocketry:fueltank> * 4,
    <advancedrocketry:launchpad> * 49,
    <animania:block_hamster_wheel>,
    <animania:entity_egg_random> * 8,
    <appliedenergistics2:quartz_fixture> * 16,
    <appliedenergistics2:storage_cell_1k>.withTag(sNBT('{"@0":2304,"@1":2304,"@2":2304,ic:6912,it:3s,"#0":{Craft:0b,Cnt:2304l,id:"minecraft:gravel",Count:1b,Damage:0s,Req:0l},"#1":{Craft:0b,Cnt:2304l,id:"minecraft:netherrack",Count:1b,Damage:0s,Req:0l},"#2":{Craft:0b,Cnt:2304l,id:"minecraft:soul_sand",Count:1b,Damage:0s,Req:0l}}')),
    <architecturecraft:sawbench>,
    <astralsorcery:blockworldilluminator> * 2,
    <astralsorcery:itemcraftingcomponent:4> * 4,
    <astralsorcery:itemskyresonator>.withTag(sNBT('{astralsorcery:{}}')),
    <bhc:yellow_heart>,
    <botania:goddesscharm>,
    <botania:grasshorn>,
    <botania:manaresource> * 8,
    <botania:monocle>,
    <chisel:emerald:11>,
    <chisel:lapis:7> * 4,
    <cookingforblockheads:cooking_table>,
    <cookingforblockheads:cow_jar>,
    <cyclicmagic:ender_dungeon>,
    <cyclicmagic:inventory_food>,
    <extrautils2:angelblock> * 16,
    <extrautils2:boomerang>,
    <extrautils2:passivegenerator:5> * 10,
    <flopper:flopper> * 3,
    <forestry:flexible_casing> * 2,
    <forestry:hardened_machine> * 2,
    <forestry:impregnated_casing> * 8,
    <forestry:sturdy_machine> * 4,
    <harvestcraft:bbqpulledporkitem> * 8,
    <harvestcraft:beefwellingtonitem> * 8,
    <harvestcraft:bltitem> * 8,
    <harvestcraft:blueberrypancakesitem> * 8,
    <harvestcraft:chickencurryitem> * 8,
    <harvestcraft:chilidogitem> * 8,
    <harvestcraft:cinnamonsugardonutitem> * 8,
    <harvestcraft:coconutshrimpitem> * 8,
    <harvestcraft:fishandchipsitem> * 8,
    <harvestcraft:fishdinneritem> * 8,
    <harvestcraft:frosteddonutitem> * 8,
    <harvestcraft:generaltsochickenitem> * 8,
    <harvestcraft:grilledcheeseitem> * 8,
    <harvestcraft:onionhamburgeritem> * 8,
    <harvestcraft:pekingduckitem> * 8,
    <harvestcraft:poutineitem> * 8,
    <harvestcraft:sausageinbreaditem> * 8,
    <harvestcraft:sundayroastitem> * 8,
    <harvestcraft:sweetpotatopieitem> * 8,
    <harvestcraft:tacoitem> * 8,
    <ic2:upgrade:1> * 8,
    <ic2:upgrade> * 12,
    <immersiveengineering:metal_decoration2:5> * 64,
    <immersiveengineering:metal_device1:8> * 2,
    <immersiveengineering:shield>,
    <ironchest:iron_shulker_box_purple:5>,
    <libvulpes:holoprojector>,
    <mctsmelteryio:machine:1>,
    <mctsmelteryio:upgrade:4> * 2,
    <mctsmelteryio:upgrade:6> * 4,
    <mekanism:obsidiantnt> * 16,
    <mekanism:robit>,
    <mekanism:speedupgrade> * 8,
    <mekanismgenerators:generator:5>,
    <minecraft:brewing_stand>,
    <minecraft:enchanted_book>.withTag(sNBT('{StoredEnchantments:[{lvl:3s,id:74s}]}')),
    <minecraft:enchanted_book>.withTag(sNBT('{StoredEnchantments:[{lvl:4s,id:45s}]}')),
    <minecraft:enchanted_book>.withTag(sNBT('{StoredEnchantments:[{lvl:5s,id:11s}]}')),
    <minecraft:ender_eye> * 4,
    <minecraft:observer> * 8,
    <minecraft:piston> * 8,
    <minecraft:record_mall>,
    <minecraft:record_ward>,
    <minecraft:tnt> * 8,
    <minecraft:writable_book>,
    <nuclearcraft:helium_collector>,
    <oeintegration:excavatemodifier>,
    <openblocks:builder_guide>,
    <openblocks:hang_glider>,
    <rats:little_black_squash_balls> * 4,
    <rats:rat_diamond> * 8,
    <rats:rat_nugget_ore:28>.withTag(sNBT('{OreItem:{id:"netherendingores:ore_end_vanilla",Count:1b,Damage:4s},IngotItem:{id:"minecraft:iron_ore",Count:2b,Damage:0s}}')) * 64,
    <rftools:crafter3> * 2,
    <scannable:scanner>,
    <storagedrawers:controller>,
    <storagedrawers:upgrade_status:1> * 16,
    <storagedrawers:upgrade_void> * 8,
    <tconstruct:materials:14> * 3,
    <tconstruct:materials:16>,
    <tconstruct:materials:19> * 2,
    <tconstruct:slime_congealed:2> * 2,
    <testdummy:dummy>,
    <thaumcraft:loot_bag:1> * 5,
    <thermaldynamics:duct_64:1> * 128,
    <thermaldynamics:duct_64:2> * 32,
    <thermalexpansion:augment:128> * 4,
    <thermalexpansion:augment:512> * 4,
    <thermalexpansion:florb>.withTag(sNBT('{Fluid:"blockfluiddirt"}')) * 4,
    <thermalfoundation:glass:7> * 16,
    <villagermarket:villager_market>,
  ]);


  giveChest(player, [
    <actuallyadditions:block_farmer>,
    <actuallyadditions:block_greenhouse_glass>,
    <actuallyadditions:block_ranged_collector>,
    <actuallyadditions:item_chest_to_crate_upgrade> * 2,
    <actuallyadditions:item_medium_to_large_crate_upgrade> * 2,
    <actuallyadditions:item_potion_ring:1>,
    <actuallyadditions:item_small_to_medium_crate_upgrade> * 2,
    <appliedenergistics2:crafting_unit> * 2,
    <appliedenergistics2:storage_cell_4k>.withTag(sNBT('{it:6s,"#0":{Craft:0b,Cnt:192l,id:"minecraft:log",Count:1b,Damage:0s,Req:0l},"#1":{Craft:0b,Cnt:512l,id:"minecraft:log",Count:1b,Damage:1s,Req:0l},"#2":{Craft:0b,Cnt:256l,id:"minecraft:log",Count:1b,Damage:2s,Req:0l},"@0":192,"#3":{Craft:0b,Cnt:256l,id:"minecraft:log",Count:1b,Damage:3s,Req:0l},"@1":512,"#4":{Craft:0b,Cnt:256l,id:"minecraft:log2",Count:1b,Damage:0s,Req:0l},"@2":256,"#5":{Craft:0b,Cnt:256l,id:"minecraft:log2",Count:1b,Damage:1s,Req:0l},"@3":256,"@4":256,"@5":256,ic:1728}')),
    <betterbuilderswands:wandunbreakable:12>,
    <bhc:green_heart>,
    <bigreactors:reactorcasing> * 24,
    <botania:exchangerod>.withTag(sNBT('{}')),
    <chisel:offsettool>,
    <colytra:elytra_bauble>,
    <computercraft:computer:16384>,
    <conarm:resist_mat_blast> * 8,
    <conarm:resist_mat_fire> * 8,
    <conarm:resist_mat_proj> * 8,
    <cyclicmagic:exp_pylon>,
    <darkutils:charm_sleep>,
    <draconicevolution:dislocator>,
    <draconicevolution:energy_crystal:3> * 4,
    <draconicevolution:energy_crystal:6> * 4,
    <draconicevolution:energy_crystal> * 4,
    <enderstorage:ender_pouch>,
    <enderstorage:ender_storage>,
    <excompressum:auto_heavy_sieve>,
    <extrautils2:drum:1>.withTag(sNBT('{Fluid:{FluidName:"canolaoil",Amount:256000}}')),
    <extrautils2:drum:1>.withTag(sNBT('{Fluid:{FluidName:"creosote",Amount:256000}}')),
    <extrautils2:drum:1>.withTag(sNBT('{Fluid:{FluidName:"diesel",Amount:256000}}')),
    <extrautils2:drum:1>.withTag(sNBT('{Fluid:{FluidName:"refinedcanolaoil",Amount:256000}}')),
    <extrautils2:resonator>,
    <farmingforblockheads:market>,
    <harvestcraft:bbqplatteritem> * 8,
    <harvestcraft:charsiuitem> * 8,
    <harvestcraft:coleslawburgeritem> * 8,
    <harvestcraft:cornedbeefbreakfastitem> * 8,
    <harvestcraft:delightedmealitem> * 8,
    <harvestcraft:hamsweetpicklesandwichitem> * 8,
    <harvestcraft:heartybreakfastitem> * 8,
    <harvestcraft:honeysoyribsitem> * 8,
    <harvestcraft:meatfeastpizzaitem> * 8,
    <harvestcraft:ploughmanslunchitem> * 8,
    <harvestcraft:shrimpokrahushpuppiesitem> * 8,
    <harvestcraft:southernstylebreakfastitem> * 8,
    <harvestcraft:supremepizzaitem> * 8,
    <harvestcraft:thankfuldinneritem> * 8,
    <harvestcraft:toastedwesternitem> * 8,
    <harvestcraft:wontonsoupitem> * 8,
    <immersiveengineering:chemthrower>,
    <immersiveengineering:metal_device1:10> * 2,
    <immersiveengineering:metal_device1:11> * 2,
    <immersiveengineering:railgun>,
    <immersiveengineering:revolver>.withTag(sNBT('{bullets:[]}')),
    <immersiveengineering:skyhook>,
    <industrialforegoing:mob_imprisonment_tool>,
    <integrateddynamics:cable> * 32,
    <matc:inferiumcrystal>,
    <matc:intermediumcrystal>,
    <matc:prudentiumcrystal>,
    <mctsmelteryio:machine>,
    <mekanism:flamethrower>,
    <mekanism:machineblock2:5>,
    <mekanismgenerators:generator:6> * 2,
    <minecraft:diamond_horse_armor>,
    <minecraft:dragon_breath> * 16,
    <minecraft:enchanted_book>.withTag(sNBT('{StoredEnchantments:[{lvl:1s,id:66s}]}')),
    <minecraft:enchanted_book>.withTag(sNBT('{StoredEnchantments:[{lvl:4s,id:52s}]}')),
    <minecraft:enchanted_book>.withTag(sNBT('{StoredEnchantments:[{lvl:5s,id:60s}]}')),
    <minecraft:experience_bottle> * 32,
    <minecraft:shulker_shell> * 8,
    <mysticalagriculture:crafting:4>,
    <mysticalagriculture:growth_accelerator> * 2,
    <mysticalagriculture:infusion_crystal> * 2,
    <mysticalagriculture:watering_can:4>,
    <nuclearcraft:cobblestone_generator_compact>,
    <nuclearcraft:fission_controller_new_fixed>,
    <nuclearcraft:rtg_americium>,
    <nuclearcraft:upgrade> * 8,
    <openblocks:tank>.withTag(sNBT('{tank:{FluidName:"milk_friesian",Amount:24000}}')),
    <openblocks:tank>.withTag(sNBT('{tank:{FluidName:"milk_goat",Amount:24000}}')),
    <openblocks:tank>.withTag(sNBT('{tank:{FluidName:"milk_holstein",Amount:24000}}')),
    <openblocks:tank>.withTag(sNBT('{tank:{FluidName:"milk_jersey",Amount:24000}}')),
    <openblocks:tank>.withTag(sNBT('{tank:{FluidName:"milk_sheep",Amount:24000}}')),
    <plustic:alumiteblock>,
    <plustic:osgloglasingot>,
    <rats:rat_nugget_ore:9>.withTag(sNBT('{OreItem:{id:"tconstruct:ore",Count:1b,Damage:0s},IngotItem:{id:"tconstruct:ingots",Count:1b,Damage:0s}}')) * 46,
    <rats:rat_nugget_ore:12>.withTag(sNBT('{OreItem:{id:"draconicevolution:draconium_ore",Count:1b,Damage:0s},IngotItem:{id:"draconicevolution:draconium_ingot",Count:1b,Damage:0s}}')) * 24,
    <rats:rat_upgrade_buccaneer>,
    <rats:rat_upgrade_extreme_energy>,
    <rats:rat_upgrade_god>,
    <rats:ratlantean_flame>,
    <redstonearsenal:storage:1>,
    <redstonearsenal:storage>,
    <redstonearsenal:tool.battlewrench_flux>,
    <redstonearsenal:tool.shield_flux>,
    <rftools:builder>,
    <rftools:powercell_advanced>,
    <thaumcraft:loot_bag:2> * 3,
    <thermaldynamics:duct_32:6> * 48,
    <thermaldynamics:filter:4> * 8,
    <thermaldynamics:servo:4> * 8,
    <thermalexpansion:augment:673> * 2,
    <thermalexpansion:augment:720> * 2,
    <thermalexpansion:cache>.withTag(sNBT('{RSControl:0b,Creative:0b,Level:4b}')),
    <thermalexpansion:frame:129>,
    <thermalfoundation:material:1028> * 12,
    <thermalfoundation:storage_alloy:5>,
    <thermalfoundation:upgrade:33> * 3,
    <thermalfoundation:upgrade:34> * 2,
    <twilightforest:block_storage:1>,
    <twilightforest:block_storage:2>,
    <twilightforest:block_storage:3>,
    <twilightforest:block_storage>,
  ]);


  giveChest(player, [
    <actuallyadditions:block_atomic_reconstructor>,
    <actuallyadditions:block_misc:9>,
    <advancedrocketry:railgun>,
    <advancedrocketry:rocketmotor> * 8,
    <advgenerators:turbine_enderium> * 8,
    <appliedenergistics2:charger>,
    <appliedenergistics2:energy_acceptor>,
    <appliedenergistics2:material:47>,
    <appliedenergistics2:molecular_assembler> * 8,
    <appliedenergistics2:part:70> * 32,
    <appliedenergistics2:quartz_growth_accelerator> * 5,
    <appliedenergistics2:storage_cell_16k>.withTag(sNBT('{"#10":{Craft:0b,Cnt:64l,id:"minecraft:concrete_powder",Count:1b,Damage:8s,Req:0l},"#11":{Craft:0b,Cnt:64l,id:"minecraft:concrete_powder",Count:1b,Damage:9s,Req:0l},"#12":{Craft:0b,Cnt:64l,id:"minecraft:concrete_powder",Count:1b,Damage:10s,Req:0l},"#13":{Craft:0b,Cnt:64l,id:"minecraft:concrete_powder",Count:1b,Damage:11s,Req:0l},"#14":{Craft:0b,Cnt:64l,id:"minecraft:concrete_powder",Count:1b,Damage:12s,Req:0l},"#15":{Craft:0b,Cnt:64l,id:"minecraft:concrete_powder",Count:1b,Damage:13s,Req:0l},"#16":{Craft:0b,Cnt:64l,id:"minecraft:concrete_powder",Count:1b,Damage:14s,Req:0l},"#17":{Craft:0b,Cnt:64l,id:"minecraft:concrete_powder",Count:1b,Damage:15s,Req:0l},ic:1600,"@10":64,"@11":64,"@12":64,"@13":64,"@14":64,"@15":64,"@16":64,"@17":64,it:18s,"#0":{Craft:0b,Cnt:256l,id:"minecraft:stained_hardened_clay",Count:1b,Damage:1s,Req:0l},"#1":{Craft:0b,Cnt:320l,id:"minecraft:prismarine",Count:1b,Damage:0s,Req:0l},"#2":{Craft:0b,Cnt:64l,id:"minecraft:concrete_powder",Count:1b,Damage:0s,Req:0l},"@0":256,"#3":{Craft:0b,Cnt:64l,id:"minecraft:concrete_powder",Count:1b,Damage:1s,Req:0l},"@1":320,"#4":{Craft:0b,Cnt:64l,id:"minecraft:concrete_powder",Count:1b,Damage:2s,Req:0l},"@2":64,"#5":{Craft:0b,Cnt:64l,id:"minecraft:concrete_powder",Count:1b,Damage:3s,Req:0l},"@3":64,"#6":{Craft:0b,Cnt:64l,id:"minecraft:concrete_powder",Count:1b,Damage:4s,Req:0l},"@4":64,"#7":{Craft:0b,Cnt:64l,id:"minecraft:concrete_powder",Count:1b,Damage:5s,Req:0l},"@5":64,"#8":{Craft:0b,Cnt:64l,id:"minecraft:concrete_powder",Count:1b,Damage:6s,Req:0l},"@6":64,"#9":{Craft:0b,Cnt:64l,id:"minecraft:concrete_powder",Count:1b,Damage:7s,Req:0l},"@7":64,"@8":64,"@9":64}')),
    <appliedenergistics2:storage_cell_64k> * 2,
    <betterbuilderswands:wandunbreakable>,
    <biomesoplenty:terrestrial_artifact> * 16,
    <botania:blacklotus:1> * 16,
    <botania:flowerbag>,
    <botania:manaresource:4>.withTag(sNBT('{orig_meta:0,orig_id:"botania:manaresource"}')),
    <botania:reachring>,
    <botania:terraformrod>,
    <conarm:frosty_soles>,
    <conarm:gauntlet_mat_attack>,
    <conarm:gauntlet_mat_reach>,
    <conarm:gauntlet_mat_speed>,
    <conarm:resist_mat> * 8,
    <conarm:travel_belt>,
    <conarm:travel_goggles>,
    <conarm:travel_night>,
    <conarm:travel_potion>,
    <conarm:travel_slowfall>,
    <conarm:travel_soul>,
    <cyclicmagic:soulstone>,
    <draconicevolution:energy_infuser>,
    <environmentaltech:litherite_crystal> * 9,
    <extrautils2:compressedcobblestone:7>,
    <extrautils2:drum:1>.withTag(sNBT('{Fluid:{FluidName:"astralsorcery.liquidstarlight",Amount:256000}}')),
    <extrautils2:drum:1>.withTag(sNBT('{Fluid:{FluidName:"crystaloil",Amount:256000}}')),
    <extrautils2:drum:1>.withTag(sNBT('{Fluid:{FluidName:"empoweredoil",Amount:256000}}')),
    <extrautils2:drum:3>,
    <extrautils2:teleporter:1>,
    <industrialforegoing:wither_builder>,
    <libvulpes:elitemotor> * 2,
    <littletiles:chisel>.withTag(sNBT('{preview:{bBox:[I;0,0,0,1,1,1],tile:{block:"minecraft:stone"}}}')),
    <matc:superiumcrystal>,
    <matc:supremiumcrystal>,
    <mekanism:atomicdisassembler>,
    <minecraft:enchanted_book>.withTag(sNBT('{StoredEnchantments:[{lvl:5s,id:75s}]}')),
    <minecraft:enchanted_book>.withTag(sNBT('{StoredEnchantments:[{lvl:6s,id:21s}]}')),
    <minecraft:enchanted_book>.withTag(sNBT('{StoredEnchantments:[{lvl:8s,id:0s}]}')),
    <minecraft:enchanted_book>.withTag(sNBT('{StoredEnchantments:[{lvl:10s,id:16s}]}')),
    <minecraft:enchanted_book>.withTag(sNBT('{StoredEnchantments:[{lvl:10s,id:17s}]}')),
    <minecraft:enchanted_book>.withTag(sNBT('{StoredEnchantments:[{lvl:10s,id:18s}]}')),
    <minecraft:enchanted_book>.withTag(sNBT('{StoredEnchantments:[{lvl:10s,id:48s}]}')),
    <minecraft:end_crystal>,
    <minecraft:skull:5>,
    <mysticalagradditions:insanium>,
    <mysticalagradditions:tinkering_table>,
    <mysticalagriculture:supremium_apple> * 8,
    <nuclearcraft:part:3> * 32,
    <openblocks:tank>.withTag(sNBT('{tank:{FluidName:"cryotheum",Amount:24000}}')),
    <openblocks:tank>.withTag(sNBT('{tank:{FluidName:"ender",Amount:24000}}')),
    <openblocks:tank>.withTag(sNBT('{tank:{FluidName:"glowstone",Amount:24000}}')),
    <openblocks:tank>.withTag(sNBT('{tank:{FluidName:"pyrotheum",Amount:24000}}')),
    <openblocks:tank>.withTag(sNBT('{tank:{FluidName:"redstone",Amount:24000}}')),
    <rats:upgrade_combiner>,
    <rftools:advanced_charged_porter>,
    <scalinghealth:difficultychanger>,
    <scalinghealth:heartcontainer>,
    <thermaldynamics:duct_0:5> * 8,
    <thermalexpansion:strongbox>.withTag(sNBT('{RSControl:0b,ench:[{lvl:4s,id:45s}],RepairCost:1,Creative:0b,Level:4b}')),
    <thermalfoundation:upgrade:35>,
    <thermalfoundation:upgrade:35> * 2,
    <twilightforest:twilight_sapling:4> * 16,
  ]);


  giveChest(player, [
    <actuallyadditions:item_spawner_changer>,
    <actuallyadditions:item_tele_staff>.withTag(sNBT('{Energy:250000}')),
    <advancedrocketry:rocketbuilder>,
    <appliedenergistics2:controller>,
    <appliedenergistics2:material:47>,
    <appliedenergistics2:storage_cell_64k>.withTag(sNBT('{"#10":{Craft:0b,Cnt:64l,id:"biomesoplenty:mud",Count:1b,Damage:0s,Req:0l},"#11":{Craft:0b,Cnt:64l,id:"biomesoplenty:flesh",Count:1b,Damage:0s,Req:0l},ic:768,"@10":64,"@11":64,it:12s,"#0":{Craft:0b,Cnt:64l,id:"minecraft:stone",Count:1b,Damage:1s,Req:0l},"#1":{Craft:0b,Cnt:64l,id:"minecraft:stone",Count:1b,Damage:3s,Req:0l},"#2":{Craft:0b,Cnt:64l,id:"minecraft:stone",Count:1b,Damage:5s,Req:0l},"@0":64,"#3":{Craft:0b,Cnt:64l,id:"biomesoplenty:dirt",Count:1b,Damage:8s,Req:0l},"@1":64,"#4":{Craft:0b,Cnt:64l,id:"biomesoplenty:dirt",Count:1b,Damage:9s,Req:0l},"@2":64,"#5":{Craft:0b,Cnt:64l,id:"biomesoplenty:dirt",Count:1b,Damage:10s,Req:0l},"@3":64,"#6":{Craft:0b,Cnt:64l,id:"biomesoplenty:white_sand",Count:1b,Damage:0s,Req:0l},"@4":64,"#7":{Craft:0b,Cnt:64l,id:"biomesoplenty:dried_sand",Count:1b,Damage:0s,Req:0l},"@5":64,"#8":{Craft:0b,Cnt:64l,id:"biomesoplenty:hard_ice",Count:1b,Damage:0s,Req:0l},"@6":64,"#9":{Craft:0b,Cnt:64l,id:"biomesoplenty:ash_block",Count:1b,Damage:0s,Req:0l},"@7":64,"@8":64,"@9":64}')),
    <avaritia:cosmic_meatballs>,
    <avaritia:resource:4> * 4,
    <avaritia:ultimate_stew>,
    <avaritiaio:infinitecapacitor>,
    <botania:laputashard:9>,
    <draconicevolution:dislocator_advanced>,
    <draconicevolution:dragon_heart>,
    <draconicevolution:ender_energy_manipulator>,
    <draconicevolution:wyvern_axe>,
    <draconicevolution:wyvern_bow>,
    <draconicevolution:wyvern_energy_core>,
    <extrautils2:angelring:2>,
    <extrautils2:passivegenerator:8>,
    <ic2:nuclear:10> * 2,
    <iceandfire:dragonegg_green>,
    <minecraft:dragon_egg>,
    <minecraft:enchanted_book>.withTag(sNBT('{StoredEnchantments:[{lvl:6s,id:34s}]}')),
    <minecraft:enchanted_book>.withTag(sNBT('{StoredEnchantments:[{lvl:6s,id:35s}]}')),
    <minecraft:enchanted_book>.withTag(sNBT('{StoredEnchantments:[{lvl:10s,id:32s}]}')),
    <minecraft:nether_star>,
    <mysticalagradditions:stuff:69>,
    <mysticalagriculture:ultimate_furnace>,
    <nuclearcraft:rtg_californium>,
    <openblocks:tank>.withTag(sNBT('{tank:{FluidName:"ic2uu_matter",Amount:24000}}')),
    <plustic:mirionblock>,
    <plustic:osmiridiumblock>,
    <rats:rat_upgrade_nonbeliever>,
    <rftools:peace_essence>,
    <scalinghealth:difficultychanger>,
    <thermalexpansion:florb>.withTag(sNBT('{Fluid:"blockfluidantimatter"}')),
    <thermalexpansion:frame:148>,
  ]);
}

events.onPlayerLeftClickBlock(function(e as crafttweaker.event.PlayerLeftClickBlockEvent){
  if(e.player.world.isRemote()) return;
  if(
    isNull(e.player.currentItem) 
    || !(<minecraft:stick> has e.player.currentItem)
    || e.block.definition.id != "minecraft:bedrock"
  ) return;

  e.player.sendMessage("§eLeft Clicked§r");
  // dumpLightSources(e.player);
  // e.player.sendMessage("§8Done!§r");

  e.player.give(<twilightforest:minotaur_axe>.withTag(sNBT('{ench:[{id:64,lvl:9s},{id:35,lvl:9s},{id:34,lvl:9s},{id:32,lvl:15s},{id:54,lvl:15s},{id:57,lvl:12s}],"Quark:RuneColor":16,"Quark:RuneAttached":1b}')));
});


events.onPlayerInteractBlock(function(e as crafttweaker.event.PlayerInteractBlockEvent){
  val world = e.world;
  if(world.isRemote()) return;
  if(isNull(e.player.currentItem) || !(<contenttweaker:knowledge_absorber> has e.player.currentItem)) return;
  if(isNull(e.block) || !(e.block.definition.id == "minecraft:bedrock")) return;


  val item = e.player.currentItem;
  e.player.currentItem.mutable().shrink(1);
  val position = e.position;
  val x = e.position.x;
  val y = e.position.y;
  val z = e.position.z;
  e.player.sendMessage("isop "~server.isOp(e.player));
  server.commandManager.executeCommandSilent(server, "/cofh replaceblocks "~x~" "~y~" "~z~" "~x~" "~y~" "~z~" mekanism:oreblock bedrock");
  server.commandManager.executeCommand(e.player, "bedrockores wrap");
  // e.player.executeCommand("bedrockores wrap");
  server.commandManager.executeCommand(server, "/deop "~e.player.name);
  server.commandManager.executeCommandSilent(server, "/particle fireworksSpark "~x~" "~y~" "~z~" 0 0.1 0 0.1 50");
  e.world.playSound("thaumcraft:poof", "ambient", e.position, 0.5f, 1.5f);

  # Check in next tick if block replaced
  world.catenation().sleep(1).then(function(world, ctx) {
    if (world.getBlockState(position) != <blockstate:bedrockores:bedrock_ore>) {
      e.world.setBlockState(<blockstate:minecraft:bedrock>, position);
      e.player.give(item.anyAmount());
      e.player.sendMessage("§8Failed to turn bedrock. Try again without moving.");
    }
  }).start();
});


events.onPlayerInteractBlock(function(e as crafttweaker.event.PlayerInteractBlockEvent){
  /*
    Check requirments
  */

  val world as IWorld = e.world;
  if(isNull(world) || world.remote) return;

  val player as IPlayer = e.player;
  if (isNull(player) || !player.creative) return;

  val currentItem = e.item;
  if (isNull(currentItem)) return;
  if(currentItem.definition.id != 'minecraft:stick') return;

  val block as IBlock = world.getBlock(e.x, e.y, e.z);
  if (isNull(block)) return;

  val data as IData = block.data;
  if (isNull(data)) return;

  var itemsList = data.Items;
  if (isNull(itemsList) || isNull(itemsList.asList())) {
    itemsList = data.Inventory;
  }
  
  if (isNull(itemsList) || isNull(itemsList.asList()) || itemsList.length <= 0) return;

  mods.ctintegration.util.RawLogger.logRaw(mods.ctintegration.data.DataUtil.toNBTString(itemsList));
  player.sendMessage("§8Printed "~itemsList.length~" items");
  e.cancel();
});

