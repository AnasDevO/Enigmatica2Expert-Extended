#modloaded jaopca
#priority -10

import crafttweaker.data.IData;
import crafttweaker.item.IIngredient;

import scripts.category.magicProcessing.magicProcessing;
import scripts.process.beneficiate;

function getOreName(name as string, part as string) as string {
  if (name.matches(part ~ '[A-Z]\\w+')) return name.substring(part.length);
  return null;
}

// Pairs of ore names and respective liquid
val ore_liquid_exceptions = {
  Aluminium      : 'aluminum',
  AstralStarmetal: 'starmetal',
} as string[string];

for ore_entry in oreDict {
  val name = ore_entry.name;

  // Ex Nihilo ore pieces conversion to ores
  var ore_name = getOreName(name, 'piece');
  if (!isNull(ore_name)) {
    if (ore_name == 'Aluminum') continue;
    val oreBlock = oreDict.get('ore' ~ ore_name);
    if (isNull(oreBlock) || oreBlock.empty) continue;

    for item in oreBlock.items {
      val asBlock = item.asBlock();
      val asBlockDef = asBlock.definition;
      if (isNull(asBlockDef) || asBlockDef.id == 'minecraft:air') continue;
      val oreBlockState = asBlockDef.getStateFromMeta(item.damage);
      val baseChance = 1.0 / 3.0;
      scripts.do.burnt_in_fluid.add(ore_entry, oreBlockState, 'stone', baseChance);
      break;
    }
    continue;
  }

  // Native clusters processing
  ore_name = getOreName(name, 'cluster');
  if (!isNull(ore_name)) {
    if (ore_name == 'Aluminum') continue;
    
    val dirtyGem = oreDict['dirtyGem' ~ ore_name].firstItem;
    if (isNull(dirtyGem)) continue;

    recipes.addShaped('beneficate native ' ~ ore_name, dirtyGem, [
      [ore_entry, ore_entry, ore_entry],
      [ore_entry, ore_entry, ore_entry]]);

    // Fix gems melting recipes
    //   Standart JAOPCA's furnace recipes for Ores that outputs
    // gems instead of ingots have empty output, so add it forced
    val smelted = utils.smelt(ore_entry);
    if (isNull(smelted)) {
      furnace.remove(<*>, ore_entry);
      val gem = utils.getSomething(ore_name, ['ingot', 'gem', 'dust', 'any'], 2);
      if (!isNull(gem)) furnace.addRecipe(gem, ore_entry);
    }

    // Add JEI entry for Thaumic Wonders
    val oreBlock = utils.getSomething(ore_name, ['ore'], 1);
    if (!isNull(oreBlock)) {
      scripts.jei.mod.thaumicwonders.addAlchemists(oreBlock * 1, ore_entry.firstItem);
    }
    val crsShard = utils.getSomething(ore_name, ['crystalShard'], 1);
    if (!isNull(crsShard)) scripts.jei.mod.thaumicwonders.addAlienists(ore_entry, crsShard * 1);

    magicProcessing(ore_entry, ore_name);
    continue;
  }

  // Crushed Ore Smeltery compat
  ore_name = getOreName(name, 'crushedPurified');
  if (!isNull(ore_name)) {
    if (ore_name == 'Aluminum') continue;
    val exception = ore_liquid_exceptions[ore_name];
    val liquid = game.getLiquid(isNull(exception) ? ore_name.toLowerCase() : exception);
    if (isNull(liquid)) continue;

    mods.tconstruct.Melting.addRecipe(liquid * 144, ore_entry);

    val unpurified = oreDict.get('crushed' ~ ore_name);
    if (isNull(unpurified) || unpurified.empty) continue;
    
    mods.tconstruct.Melting.addRecipe(liquid * 144, unpurified);
    continue;
  }

  // Dense plates in Thermal Expansion Compactor
  ore_name = getOreName(name, 'plateDense');
  if (!isNull(ore_name)) {
    if (ore_name == 'Aluminum') continue;
    val inpOre = (ore_name == 'Obsidian')
      ? (<minecraft:obsidian> * 3) as IIngredient
      : oreDict['block' ~ ore_name];
    if (inpOre.items.length <= 0) continue;
    scripts.process.compress(inpOre, ore_entry.firstItem, 'only: Compactor');
    mods.immersiveengineering.MetalPress.addRecipe(ore_entry.firstItem, oreDict['plate' ~ ore_name], <immersiveengineering:mold:6>, 16000, 9);
    continue;
  }

  // Dirty ore additional IC2 compat
  ore_name = getOreName(name, 'dustDirty');
  if (!isNull(ore_name)) {
    if (ore_name == 'Aluminum') continue;

    val output = oreDict.get('crushedPurified' ~ ore_name);
    if (isNull(output) || output.empty) continue;

    mods.ic2.OreWasher.addRecipe([output.firstItem], ore_entry);

    continue;
  }
}


// static benOpts as IData = {
//   exceptions       : 'Pulverizer StarlightInfuser',
//   meltingExceptions: scripts.vars.meltingExceptions,
// } as IData;
// 
// for ore_name, outputs in {
// /*Inject_js!!!!!!!{
// val clusters = Object.entries(getByOreKind('cluster')).filter(([base])=>!['Yellorium','Aluminum'].includes(base))
// val furnInputs = new Set(getUnchangedFurnaceRecipes().map(r=>r.input))
// val noFurn = new Set(clusters.map(([,tm])=>tm.commandString).filter(cs=>!furnInputs.has(cs)))

// return clusters.map(([base,tm])=>{
//   val result = noFurn.has(tm.commandString) ? getSomething(base, ["ingot", "gem", "dust", "any"], ["cluster", "ore"]) : undefined
//   return [
//   `${base}`,
//   `: [${tm.commandString}`,
//   `, ${result?.withAmount(countBaseOutput(base, 2)) ?? 'null'}`,
//   `],${result ? ' # '+result.display : ''}`
// ]})
// }*/
// Aluminium          : [<jaopca:thaumcraft_cluster.aluminium>          , <thermalfoundation:material:132> * 2       ], # Aluminum Ingot
// Amber              : [<jaopca:thaumcraft_cluster.amber>              , <biomesoplenty:gem:7> * 4                  ], # Amber
// Amethyst           : [<jaopca:thaumcraft_cluster.amethyst>           , <biomesoplenty:gem> * 4                    ], # Ender Amethyst
// Apatite            : [<jaopca:thaumcraft_cluster.apatite>            , <forestry:apatite> * 20                    ], # Apatite
// Aquamarine         : [<jaopca:thaumcraft_cluster.aquamarine>         , <astralsorcery:itemcraftingcomponent> * 8  ], # Aquamarine
// Ardite             : [<jaopca:thaumcraft_cluster.ardite>             , <tconstruct:ingots:1> * 2                  ], # Ardite Ingot
// AstralStarmetal    : [<jaopca:thaumcraft_cluster.astralstarmetal>    , <astralsorcery:itemcraftingcomponent:1> * 2], # Starmetal Ingot
// Boron              : [<jaopca:thaumcraft_cluster.boron>              , <nuclearcraft:ingot:5> * 2                 ], # Boron Ingot
// CertusQuartz       : [<jaopca:thaumcraft_cluster.certusquartz>       , <appliedenergistics2:material> * 6         ], # Certus Quartz Crystal
// ChargedCertusQuartz: [<jaopca:thaumcraft_cluster.chargedcertusquartz>, <appliedenergistics2:material:1> * 4       ], # Charged Certus Quartz Crystal
// Coal               : [<jaopca:thaumcraft_cluster.coal>               , <minecraft:coal> * 10                      ], # Coal
// Cobalt             : [<jaopca:thaumcraft_cluster.cobalt>             , <tconstruct:ingots> * 2                    ], # Cobalt Ingot
// Diamond            : [<jaopca:thaumcraft_cluster.diamond>            , <minecraft:diamond> * 4                    ], # Diamond
// Dilithium          : [<jaopca:thaumcraft_cluster.dilithium>          , <libvulpes:productgem> * 2                 ], # Dilithium Crystal
// DimensionalShard   : [<jaopca:thaumcraft_cluster.dimensionalshard>   , <rftools:dimensional_shard> * 6            ], # Dimensional Shard
// Draconium          : [<jaopca:thaumcraft_cluster.draconium>          , <draconicevolution:draconium_ingot> * 2    ], # Draconium Ingot
// Emerald            : [<jaopca:thaumcraft_cluster.emerald>            , <minecraft:emerald> * 4                    ], # Emerald
// Iridium            : [<jaopca:thaumcraft_cluster.iridium>            , <thermalfoundation:material:135> * 2       ], # Iridium Ingot
// Lapis              : [<jaopca:thaumcraft_cluster.lapis>              , <minecraft:dye:4> * 20                     ], # Lapis Lazuli
// Lithium            : [<jaopca:thaumcraft_cluster.lithium>            , <nuclearcraft:ingot:6> * 2                 ], # Lithium Ingot
// Magnesium          : [<jaopca:thaumcraft_cluster.magnesium>          , <nuclearcraft:ingot:7> * 2                 ], # Magnesium Ingot
// Malachite          : [<jaopca:thaumcraft_cluster.malachite>          , <biomesoplenty:gem:5> * 4                  ], # Malachite
// Mithril            : [<jaopca:thaumcraft_cluster.mithril>            , <thermalfoundation:material:136> * 2       ], # Mana Infused Ingot
// Nickel             : [<jaopca:thaumcraft_cluster.nickel>             , <thermalfoundation:material:133> * 2       ], # Nickel Ingot
// Osmium             : [<jaopca:thaumcraft_cluster.osmium>             , <mekanism:ingot:1> * 2                     ], # Osmium Ingot
// Peridot            : [<jaopca:thaumcraft_cluster.peridot>            , <biomesoplenty:gem:2> * 4                  ], # Peridot
// Platinum           : [<jaopca:thaumcraft_cluster.platinum>           , <thermalfoundation:material:134> * 2       ], # Platinum Ingot
// QuartzBlack        : [<jaopca:thaumcraft_cluster.quartzblack>        , <actuallyadditions:item_misc:5> * 4        ], # Black Quartz
// Redstone           : [<jaopca:thaumcraft_cluster.redstone>           , <extrautils2:ingredients> * 20             ], # Resonating Redstone Crystal
// Ruby               : [<jaopca:thaumcraft_cluster.ruby>               , <biomesoplenty:gem:1> * 4                  ], # Ruby
// Sapphire           : [<jaopca:thaumcraft_cluster.sapphire>           , <biomesoplenty:gem:6> * 4                  ], # Sapphire
// Tanzanite          : [<jaopca:thaumcraft_cluster.tanzanite>          , <biomesoplenty:gem:4> * 4                  ], # Tanzanite
// Thorium            : [<jaopca:thaumcraft_cluster.thorium>            , <nuclearcraft:ingot:3> * 2                 ], # Thorium Ingot
// Titanium           : [<jaopca:thaumcraft_cluster.titanium>           , <libvulpes:productingot:7> * 2             ], # Titanium Ingot
// Topaz              : [<jaopca:thaumcraft_cluster.topaz>              , <biomesoplenty:gem:3> * 4                  ], # Topaz
// Uranium            : [<jaopca:thaumcraft_cluster.uranium>            , <immersiveengineering:metal:5> * 2         ], # Uranium Ingot
// Iron               : [<thaumcraft:cluster>                    , <minecraft:iron_ingot> * 2                 ], # Iron Ingot
// Gold               : [<thaumcraft:cluster:1>                  , <minecraft:gold_ingot> * 2                 ], # Gold Ingot
// Copper             : [<thaumcraft:cluster:2>                  , null                                       ],
// Tin                : [<thaumcraft:cluster:3>                  , null                                       ],
// Silver             : [<thaumcraft:cluster:4>                  , null                                       ],
// Lead               : [<thaumcraft:cluster:5>                  , null                                       ],
// Cinnabar           : [<thaumcraft:cluster:6>                  , <thaumcraft:quicksilver> * 2               ], # Quicksilver
// Quartz             : [<thaumcraft:cluster:7>                  , <minecraft:quartz> * 6                     ], # Nether Quartz
// /**/
// } as IItemStack[][string] {
//   val ore_entry = oreDict.get("cluster" ~ ore_name);
//   beneficiate(ore_entry, ore_name, 3, benOpts);
//   magicProcessing(ore_entry, ore_name);

//   # Fix gems melting recipes
//   #   Standart JAOPCA's furnace recipes for Ores that outputs
//   # gems instead of ingots have empty output, so add it forced
//   var smelted = utils.smelt(ore_entry);
//   if (isNull(smelted)) {
//     furnace.remove(<*>, ore_entry);
//     var gem = utils.getSomething(ore_name, ["gem", "dust", "any"], 2);
//     if(!isNull(gem)) furnace.addRecipe(gem, ore_entry, 3.0);
//   }
// }
