#modloaded requious
#priority -150

import crafttweaker.data.IData;
import crafttweaker.item.IIngredient;
import crafttweaker.item.IItemStack;
import crafttweaker.world.IVector3d.create as V;
import mods.requious.AssemblyRecipe;
import mods.requious.Color;
import mods.requious.ComponentFace;
import mods.requious.GaugeDirection;
import mods.requious.MachineVisual;
import mods.requious.RecipeContainer;
import mods.requious.SlotVisual;

// [Infinity_Furnace] from [Infinity_Fuel][+4]
craft.remake(<requious:infinity_furnace>, ['pretty',
  'T R E R T',
  '# ▬ n ▬ #',
  'H r I r H',
  '# ▬ Ϟ ▬ #',
  'T R E R T'], {
  'R': <rats:rat_upgrade_basic_ratlantean>,
  '#': <ore:logSequoia>,                          // Sequoia
  'T': <mysticalagriculture:supremium_furnace>,
  'E': <contenttweaker:empowered_phosphor>,       // Empowered Phosphor
  'r': <rats:idol_of_ratlantis>,
  'H': <scalinghealth:heartcontainer>,            // Heart Container
  'I': <avaritia:singularity:12>,
  '▬': <ore:dragonsteelIngot>,
  'n': <randomthings:spectrecoil_ender>,          // Ender Spectre Coil
  'Ϟ': <randomthings:spectreenergyinjector>,       // Spectre Energy Injector
});

// -----------------------------------------------------------------------
// -----------------------------------------------------------------------

val o = <assembly:infinity_furnace>;
static inpX as int = 3; static inpY as int = 2;
o.setItemSlot(inpX,inpY,ComponentFace.all(),64).setAccess(true,false).setGroup('input');

static outX as int = 5; static outY as int = 2;
o.setItemSlot(outX,outY,ComponentFace.all(),64).setAccess(false,true).setHandAccess(false,true).setGroup('output');
o.setDurationSlot(4,2).setVisual(SlotVisual.createGauge('requious:textures/gui/assembly_gauges.png',2,1,3,1,GaugeDirection.up(),false)).setGroup('duration');

o.setJEIItemSlot(inpX,inpY, 'input');
o.setJEIItemSlot(outX,outY, 'output');
o.setJEIDurationSlot(4,2,'duration', SlotVisual.create(1,1).addPart('requious:textures/gui/assembly_gauges.png',3,1));

o.addVisual(MachineVisual.flame('active'.asVariable(), V(-0.1, -0.1, -0.1), V(1.1, 1.1, 1.1), V(0, 0, 0), 30, 1, 3, Color.normal([96, 56, 134])));

// -------------------------------------------------------------------------------
// -------------------------------------------------------------------------------

function infinFurnace(inp as IIngredient, out as IItemStack) as void {
  if (isNull(inp) || isNull(out)) return;

  val assRecipe = AssemblyRecipe.create(function (c) {
    c.addItemOutput('output', out * min(64, out.amount * 4));
  })
    .requireItem('input', inp)
    .requireDuration('duration', 1);

  <assembly:infinity_furnace>.addJEIRecipe(assRecipe);
}

// Wildcard
static W as int = <minecraft:dirt:*>.damage;

static blacklistedInput as bool[IItemStack] = {} as bool[IItemStack];
static blacklistedWildcard as bool[string] = {} as bool[string];

function blacklist(id as string, damage as int = 0, amount as int = 1, tag as IData = null) as void {
  // Wildcarded input
  if (damage == W) {
    blacklistedWildcard[id] = true;
  }
  else {
    val item = utils.get(id, damage/* , amount, tag */);
    if (isNull(item)) {
      utils.log('Cant find item for blacklisting in Infinity Furnace: ' ~ id ~ ':' ~ damage);
      return;
    }
    blacklistedInput[item] = true;
  }
}

static cachedOutput as IItemStack[IItemStack] = {} as IItemStack[IItemStack];

function pushToOutput(output as IItemStack, c as RecipeContainer) as bool {
  val outStack = c.machine.getItem(outX, outY);

  // Slot is empty
  if (isNull(outStack)) {
    c.machine.setItem(outX, outY, output);
    return true;
  }

  // Stacks cant be merged
  if (
    outStack.definition.id != output.definition.id
    || outStack.damage != output.damage
    || outStack.tag != output.tag
    || outStack.capNBT != output.capNBT
  ) return false;

  // Not anough space
  if (outStack.maxStackSize - outStack.amount < output.amount) return false;

  // Merge stacks
  c.machine.setItem(outX, outY, outStack.withAmount(outStack.amount + output.amount));
  return true;
}

<assembly:infinity_furnace>.addRecipe(
  AssemblyRecipe.create(function (c) {
    val inputStack = c.machine.getItem(inpX, inpY);
    if (isNull(inputStack)) return;
    val input = inputStack.anyAmount();

    if (!isNull(blacklistedWildcard[input.definition.id])
      || !isNull(blacklistedInput[input]))
      return;

    var smelted = cachedOutput[input];

    // Add cache
    if (isNull(smelted)) {
      smelted = utils.smelt(input);

      // Item is unsmeltable, mark it
      if (isNull(smelted)) {
        cachedOutput[input] = input;
        return;
      }

      cachedOutput[input] = smelted;
    }
    else if (
      input.definition.id == smelted.definition.id
      && input.damage == smelted.damage
    ) return; // Item is unsmeltable

    if (pushToOutput(smelted * min(64, smelted.amount * 4), c))
      c.machine.setItem(inpX, inpY, inputStack.amount > 1 ? inputStack.withAmount(inputStack.amount - 1) : null);
  })
    .requireWorldCondition('has_input', function (m) {
    val inputStack = m.getItem(inpX, inpY);
      if (isNull(inputStack)) return false;
      val input = inputStack.anyAmount();

      // Skip if blacklisted
      if (!isNull(blacklistedWildcard[input.definition.id])
        || !isNull(blacklistedInput[input]))
        return false;
      return true;
    }, 1)
    .setActive(5)
    .requireDuration('duration', 1)
);

// Special case for logWood -> Charcoal
infinFurnace(<ore:logWood>, <minecraft:coal:1>);

/* Inject_js{

// Manual antidupe list
const manualBlacklist = new Set(`
biomesoplenty:mud
biomesoplenty:mudball
botania:biomestonea
ic2:dust:3
iceandfire:dread_stone_bricks
minecraft:sponge:1
minecraft:stonebrick
mysticalagriculture:soulstone:1
nuclearcraft:ingot:15
rats:marbled_cheese_brick
rustic:dust_tiny_iron
tcomplement:scorched_block:3
tcomplement:scorched_slab:3
tcomplement:scorched_stairs_brick
tconstruct:brownstone:3
tconstruct:seared:3
thermalfoundation:material:864
`.trim().split('\n'))

const commandString = (id, meta, nbt, amount) => {
  let s = `'${id}'`
  ;(meta || amount || nbt) && (s += `, ${meta === '*' ? 'W' : (meta || 0)}`)
  ;((amount && parseInt(amount) > 1) || nbt) && (s += `, ${amount || 1}`)
  ;(nbt) && (s += `, ${nbt}`)
  return s
}

let blacklisted = 0
let oredictFiltered = 0

function composeRecipe({ out_id, out_meta, out_tag, out_amount, in_id, in_meta, in_tag, in_amount }) {
  const involved = [[in_id, in_meta], [out_id, out_meta]]

  // Blacklist
  const inpCommandStr = commandString(in_id, in_meta, in_tag, in_amount)
  if (
    involved.some(([id, meta]) => isJEIBlacklisted(id, meta))
    || manualBlacklist.has(in_id + ((in_meta && in_meta !== '*') ? `:${in_meta}` : ''))
    || manualBlacklist.has(in_id)
  )
    return blacklisted++, `blacklist(${inpCommandStr});`

  const in_ore = [...getItemOredictSet(in_id, in_meta).keys()]

  // Just skip
  if (in_ore.includes('logWood')) return `// SKIP: ${inpCommandStr}`

  const out_ore = [...getItemOredictSet(out_id, out_meta).keys()]
  if (in_ore.some((o) => {
    const mat = o.match(/^dust([A-Z].+)/)?.[1]
    return mat && out_ore.some(o => o.replace(/^(ingot|gem)/, '') === mat)
  })
    // Blacklist input
    || ['Oxide', 'Nitride', 'ZA']
      .some(key => in_ore.some(o => o.match(new RegExp(`.+${key}`))))
  ) return oredictFiltered++, `blacklist(${inpCommandStr});`

  return `infinFurnace(utils.get(${
    inpCommandStr}), utils.get(${
    commandString(out_id, out_meta, out_tag, out_amount)}));`
}

const furnaceRecipes = getFurnaceRecipes()
if (!furnaceRecipes) return undefined
const filtered = furnaceRecipes.map(composeRecipe)

return `
// Total Furnace recipes registered: ${furnaceRecipes.length}
// Blacklisted by JEI or manually: ${blacklisted}
// Filtered by oredict: ${oredictFiltered}
${filtered.join('\n')}`

} */

// Total Furnace recipes registered: 939
// Blacklisted by JEI or manually: 77
// Filtered by oredict: 156
infinFurnace(utils.get('actuallyadditions:block_misc', 3), utils.get('actuallyadditions:item_misc', 5));
blacklist('actuallyadditions:item_dust', 3);
blacklist('actuallyadditions:item_dust', 7);
infinFurnace(utils.get('actuallyadditions:item_misc', 4), utils.get('actuallyadditions:item_food', 15));
infinFurnace(utils.get('actuallyadditions:item_misc', 9), utils.get('actuallyadditions:item_food', 17));
infinFurnace(utils.get('actuallyadditions:item_misc', 20), utils.get('minecraft:iron_ingot', 0, 2));
infinFurnace(utils.get('actuallyadditions:item_misc', 21), utils.get('actuallyadditions:item_misc', 22));
blacklist('advancedrocketry:productdust', 1);
blacklist('advancedrocketry:productdust');
infinFurnace(utils.get('appliedenergistics2:material', 2), utils.get('appliedenergistics2:material', 5));
infinFurnace(utils.get('appliedenergistics2:material', 3), utils.get('appliedenergistics2:material', 5));
infinFurnace(utils.get('appliedenergistics2:material', 4), utils.get('minecraft:bread'));
blacklist('appliedenergistics2:material', 49);
blacklist('appliedenergistics2:material', 51);
infinFurnace(utils.get('appliedenergistics2:sky_stone_block'), utils.get('appliedenergistics2:smooth_sky_stone_block'));
infinFurnace(utils.get('astralsorcery:blockcustomore', 1), utils.get('astralsorcery:itemcraftingcomponent', 1));
infinFurnace(utils.get('astralsorcery:blockcustomsandore'), utils.get('astralsorcery:itemcraftingcomponent', 0, 3));
blacklist('betteranimalsplus:crab_meat_raw');
infinFurnace(utils.get('betteranimalsplus:eel_meat_raw'), utils.get('betteranimalsplus:eel_meat_cooked'));
infinFurnace(utils.get('betteranimalsplus:golden_goose_egg'), utils.get('minecraft:gold_ingot'));
infinFurnace(utils.get('betteranimalsplus:goose_egg'), utils.get('betteranimalsplus:fried_egg'));
infinFurnace(utils.get('betteranimalsplus:pheasant_egg'), utils.get('betteranimalsplus:fried_egg'));
infinFurnace(utils.get('betteranimalsplus:pheasantraw'), utils.get('betteranimalsplus:pheasantcooked'));
infinFurnace(utils.get('betteranimalsplus:turkey_egg'), utils.get('betteranimalsplus:fried_egg'));
infinFurnace(utils.get('betteranimalsplus:turkey_raw'), utils.get('betteranimalsplus:turkey_cooked'));
infinFurnace(utils.get('betteranimalsplus:venisonraw'), utils.get('betteranimalsplus:venisoncooked'));
infinFurnace(utils.get('biomesoplenty:gem_ore', 1), utils.get('biomesoplenty:gem', 1));
infinFurnace(utils.get('biomesoplenty:gem_ore', 2), utils.get('biomesoplenty:gem', 2));
infinFurnace(utils.get('biomesoplenty:gem_ore', 3), utils.get('biomesoplenty:gem', 3));
infinFurnace(utils.get('biomesoplenty:gem_ore', 4), utils.get('biomesoplenty:gem', 4));
infinFurnace(utils.get('biomesoplenty:gem_ore', 5), utils.get('biomesoplenty:gem', 5));
infinFurnace(utils.get('biomesoplenty:gem_ore', 6), utils.get('biomesoplenty:gem', 6));
infinFurnace(utils.get('biomesoplenty:gem_ore'), utils.get('biomesoplenty:gem'));
// SKIP: 'biomesoplenty:log_0', 4
// SKIP: 'biomesoplenty:log_0', 5
// SKIP: 'biomesoplenty:log_0', 6
// SKIP: 'biomesoplenty:log_0', 7
// SKIP: 'biomesoplenty:log_1', 4
// SKIP: 'biomesoplenty:log_1', 5
// SKIP: 'biomesoplenty:log_1', 6
// SKIP: 'biomesoplenty:log_1', 7
// SKIP: 'biomesoplenty:log_2', 4
// SKIP: 'biomesoplenty:log_2', 5
// SKIP: 'biomesoplenty:log_2', 6
// SKIP: 'biomesoplenty:log_2', 7
// SKIP: 'biomesoplenty:log_3', 4
// SKIP: 'biomesoplenty:log_3', 5
// SKIP: 'biomesoplenty:log_3', 6
// SKIP: 'biomesoplenty:log_3', 7
// SKIP: 'biomesoplenty:log_4', 5
blacklist('biomesoplenty:mud');
blacklist('biomesoplenty:mudball');
infinFurnace(utils.get('biomesoplenty:plant_1', 6), utils.get('minecraft:dye', 2));
infinFurnace(utils.get('biomesoplenty:white_sand'), utils.get('minecraft:glass'));
blacklist('bloodmagic:component', 19);
blacklist('bloodmagic:component', 20);
blacklist('botania:biomestonea', 8);
blacklist('botania:biomestonea', 9);
blacklist('botania:biomestonea', 10);
blacklist('botania:biomestonea', 11);
blacklist('botania:biomestonea', 12);
blacklist('botania:biomestonea', 13);
blacklist('botania:biomestonea', 14);
blacklist('botania:biomestonea', 15);
infinFurnace(utils.get('cathedral:claytile'), utils.get('cathedral:firedtile'));
infinFurnace(utils.get('claybucket:unfiredclaybucket', W), utils.get('claybucket:claybucket'));
infinFurnace(utils.get('contenttweaker:ore_phosphor'), utils.get('contenttweaker:nugget_phosphor'));
infinFurnace(utils.get('cookingforblockheads:recipe_book'), utils.get('cookingforblockheads:recipe_book', 1));
blacklist('draconicevolution:draconium_dust', W);
infinFurnace(utils.get('draconicevolution:draconium_ore', 1), utils.get('draconicevolution:draconium_ore', 0, 2));
infinFurnace(utils.get('draconicevolution:draconium_ore', 2), utils.get('draconicevolution:draconium_ore', 0, 2));
blacklist('enderio:item_material', 21);
blacklist('enderio:item_material', 24);
blacklist('enderio:item_material', 25);
blacklist('enderio:item_material', 26);
blacklist('enderio:item_material', 27);
blacklist('enderio:item_material', 30);
blacklist('enderio:item_material', 31);
blacklist('enderio:item_material', 74);
blacklist('enderio:item_owl_egg');
infinFurnace(utils.get('endreborn:block_wolframium_ore', W), utils.get('endreborn:item_ingot_wolframium'));
infinFurnace(utils.get('exnihilocreatio:item_material', 2), utils.get('exnihilocreatio:item_cooked_silkworm'));
blacklist('exnihilocreatio:item_ore_ardite', 2);
blacklist('exnihilocreatio:item_ore_cobalt', 2);
infinFurnace(utils.get('extrautils2:decorativesolid', 4), utils.get('extrautils2:decorativeglass'));
// SKIP: 'extrautils2:ironwood_log', W
infinFurnace(utils.get('forestry:ash'), utils.get('tconstruct:materials'));
// SKIP: 'forestry:logs.0', W
// SKIP: 'forestry:logs.1', W
// SKIP: 'forestry:logs.2', W
// SKIP: 'forestry:logs.3', W
// SKIP: 'forestry:logs.4', W
// SKIP: 'forestry:logs.5', W
// SKIP: 'forestry:logs.6', W
// SKIP: 'forestry:logs.7', W
infinFurnace(utils.get('forestry:peat'), utils.get('forestry:ash'));
infinFurnace(utils.get('forestry:resources'), utils.get('forestry:apatite'));
blacklist('gendustry:gene_sample', W);
blacklist('gendustry:gene_template', W);
infinFurnace(utils.get('gendustry:honey_drop', 5), utils.get('appliedenergistics2:material', 5, 2));
infinFurnace(utils.get('harvestcraft:anchovyrawitem', W), utils.get('minecraft:cooked_fish'));
infinFurnace(utils.get('harvestcraft:bassrawitem', W), utils.get('minecraft:cooked_fish'));
infinFurnace(utils.get('harvestcraft:calamarirawitem', W), utils.get('harvestcraft:calamaricookeditem'));
infinFurnace(utils.get('harvestcraft:carprawitem', W), utils.get('minecraft:cooked_fish'));
infinFurnace(utils.get('harvestcraft:catfishrawitem', W), utils.get('minecraft:cooked_fish'));
infinFurnace(utils.get('harvestcraft:charrrawitem', W), utils.get('minecraft:cooked_fish'));
infinFurnace(utils.get('harvestcraft:clamrawitem', W), utils.get('harvestcraft:clamcookeditem'));
infinFurnace(utils.get('harvestcraft:crabrawitem', W), utils.get('harvestcraft:crabcookeditem'));
infinFurnace(utils.get('harvestcraft:crayfishrawitem', W), utils.get('harvestcraft:crayfishcookeditem'));
infinFurnace(utils.get('harvestcraft:duckrawitem', W), utils.get('harvestcraft:duckcookeditem'));
infinFurnace(utils.get('harvestcraft:eelrawitem', W), utils.get('minecraft:cooked_fish'));
infinFurnace(utils.get('harvestcraft:frograwitem', W), utils.get('harvestcraft:frogcookeditem'));
infinFurnace(utils.get('harvestcraft:greenheartfishitem', W), utils.get('minecraft:cooked_fish'));
infinFurnace(utils.get('harvestcraft:grouperrawitem', W), utils.get('minecraft:cooked_fish'));
infinFurnace(utils.get('harvestcraft:grubitem', W), utils.get('harvestcraft:cookedgrubitem'));
infinFurnace(utils.get('harvestcraft:herringrawitem', W), utils.get('minecraft:cooked_fish'));
infinFurnace(utils.get('harvestcraft:mudfishrawitem', W), utils.get('minecraft:cooked_fish'));
infinFurnace(utils.get('harvestcraft:musselrawitem', W), utils.get('harvestcraft:musselcookeditem'));
infinFurnace(utils.get('harvestcraft:octopusrawitem', W), utils.get('harvestcraft:octopuscookeditem'));
infinFurnace(utils.get('harvestcraft:oysterrawitem', W), utils.get('harvestcraft:oystercookeditem'));
infinFurnace(utils.get('harvestcraft:perchrawitem', W), utils.get('minecraft:cooked_fish'));
infinFurnace(utils.get('harvestcraft:rawtofabbititem', W), utils.get('harvestcraft:cookedtofabbititem'));
infinFurnace(utils.get('harvestcraft:rawtofaconitem', W), utils.get('harvestcraft:cookedtofaconitem'));
infinFurnace(utils.get('harvestcraft:rawtofeakitem', W), utils.get('harvestcraft:cookedtofeakitem'));
infinFurnace(utils.get('harvestcraft:rawtofeegitem', W), utils.get('harvestcraft:cookedtofeegitem'));
infinFurnace(utils.get('harvestcraft:rawtofenisonitem', W), utils.get('harvestcraft:cookedtofenisonitem'));
infinFurnace(utils.get('harvestcraft:rawtofickenitem', W), utils.get('harvestcraft:cookedtofickenitem'));
infinFurnace(utils.get('harvestcraft:rawtofishitem', W), utils.get('harvestcraft:cookedtofishitem'));
infinFurnace(utils.get('harvestcraft:rawtofuduckitem', W), utils.get('harvestcraft:cookedtofuduckitem'));
infinFurnace(utils.get('harvestcraft:rawtofurkeyitem', W), utils.get('harvestcraft:cookedtofurkeyitem'));
infinFurnace(utils.get('harvestcraft:rawtofuttonitem', W), utils.get('harvestcraft:cookedtofuttonitem'));
infinFurnace(utils.get('harvestcraft:sardinerawitem', W), utils.get('minecraft:cooked_fish'));
infinFurnace(utils.get('harvestcraft:scalloprawitem', W), utils.get('harvestcraft:scallopcookeditem'));
infinFurnace(utils.get('harvestcraft:shrimprawitem', W), utils.get('harvestcraft:shrimpcookeditem'));
infinFurnace(utils.get('harvestcraft:snailrawitem', W), utils.get('harvestcraft:snailcookeditem'));
infinFurnace(utils.get('harvestcraft:snapperrawitem', W), utils.get('minecraft:cooked_fish'));
infinFurnace(utils.get('harvestcraft:tilapiarawitem', W), utils.get('minecraft:cooked_fish'));
infinFurnace(utils.get('harvestcraft:troutrawitem', W), utils.get('minecraft:cooked_fish'));
infinFurnace(utils.get('harvestcraft:tunarawitem', W), utils.get('minecraft:cooked_fish'));
infinFurnace(utils.get('harvestcraft:turkeyrawitem', W), utils.get('harvestcraft:turkeycookeditem'));
infinFurnace(utils.get('harvestcraft:turtlerawitem', W), utils.get('harvestcraft:turtlecookeditem'));
infinFurnace(utils.get('harvestcraft:venisonrawitem', W), utils.get('harvestcraft:venisoncookeditem'));
infinFurnace(utils.get('harvestcraft:walleyerawitem', W), utils.get('minecraft:cooked_fish'));
infinFurnace(utils.get('ic2:crafting', 27), utils.get('ic2:crystal_memory'));
infinFurnace(utils.get('ic2:crushed', 1), utils.get('minecraft:gold_ingot'));
infinFurnace(utils.get('ic2:crushed', 2), utils.get('minecraft:iron_ingot'));
infinFurnace(utils.get('ic2:crushed', 3), utils.get('thermalfoundation:material', 131));
infinFurnace(utils.get('ic2:crushed', 4), utils.get('thermalfoundation:material', 130));
infinFurnace(utils.get('ic2:crushed', 5), utils.get('thermalfoundation:material', 129));
infinFurnace(utils.get('ic2:crushed', 6), utils.get('immersiveengineering:metal', 5));
infinFurnace(utils.get('ic2:crushed'), utils.get('thermalfoundation:material', 128));
blacklist('ic2:dust', 3);
blacklist('ic2:dust', 11);
infinFurnace(utils.get('ic2:dust', 15), utils.get('tconstruct:materials'));
infinFurnace(utils.get('ic2:misc_resource', 4), utils.get('ic2:crafting'));
infinFurnace(utils.get('ic2:mug', 1), utils.get('ic2:mug', 2));
infinFurnace(utils.get('ic2:purified', 1), utils.get('minecraft:gold_ingot'));
infinFurnace(utils.get('ic2:purified', 2), utils.get('minecraft:iron_ingot'));
infinFurnace(utils.get('ic2:purified', 3), utils.get('thermalfoundation:material', 131));
infinFurnace(utils.get('ic2:purified', 4), utils.get('thermalfoundation:material', 130));
infinFurnace(utils.get('ic2:purified', 5), utils.get('thermalfoundation:material', 129));
infinFurnace(utils.get('ic2:purified', 6), utils.get('immersiveengineering:metal', 5));
infinFurnace(utils.get('ic2:purified'), utils.get('thermalfoundation:material', 128));
// SKIP: 'ic2:rubber_wood', W
blacklist('iceandfire:dread_stone_bricks', W);
infinFurnace(utils.get('iceandfire:frozen_cobblestone', W), utils.get('minecraft:cobblestone'));
infinFurnace(utils.get('iceandfire:frozen_dirt', W), utils.get('minecraft:dirt'));
infinFurnace(utils.get('iceandfire:frozen_grass_path', W), utils.get('minecraft:grass_path'));
infinFurnace(utils.get('iceandfire:frozen_grass', W), utils.get('minecraft:grass'));
infinFurnace(utils.get('iceandfire:frozen_gravel', W), utils.get('minecraft:gravel'));
infinFurnace(utils.get('iceandfire:frozen_splinters', W), utils.get('minecraft:stick', 0, 3));
infinFurnace(utils.get('iceandfire:frozen_stone', W), utils.get('minecraft:stone'));
infinFurnace(utils.get('iceandfire:stymphalian_bird_feather', W), utils.get('thermalfoundation:material', 227));
infinFurnace(utils.get('immersiveengineering:material', 7), utils.get('thermalfoundation:rockwool', 7));
blacklist('immersiveengineering:material', 18);
blacklist('immersiveengineering:metal', 14);
infinFurnace(utils.get('immersiveengineering:ore', 5), utils.get('immersiveengineering:metal', 5));
infinFurnace(utils.get('industrialforegoing:dryrubber', W), utils.get('industrialforegoing:plastic'));
// SKIP: 'integrateddynamics:menril_log_filled'
// SKIP: 'integrateddynamics:menril_log'
infinFurnace(utils.get('jaopca:magneticraft_chunk.aluminium'), utils.get('jaopca:skyresources_dirty_gem.aluminium', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.amber'), utils.get('jaopca:skyresources_dirty_gem.amber', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.amethyst'), utils.get('jaopca:skyresources_dirty_gem.amethyst', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.anglesite'), utils.get('jaopca:skyresources_dirty_gem.anglesite', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.apatite'), utils.get('jaopca:skyresources_dirty_gem.apatite', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.aquamarine'), utils.get('jaopca:skyresources_dirty_gem.aquamarine', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.ardite'), utils.get('jaopca:skyresources_dirty_gem.ardite', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.astralstarmetal'), utils.get('jaopca:skyresources_dirty_gem.astralstarmetal', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.benitoite'), utils.get('jaopca:skyresources_dirty_gem.benitoite', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.boron'), utils.get('jaopca:skyresources_dirty_gem.boron', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.certusquartz'), utils.get('jaopca:skyresources_dirty_gem.certusquartz', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.chargedcertusquartz'), utils.get('jaopca:skyresources_dirty_gem.chargedcertusquartz', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.coal'), utils.get('jaopca:skyresources_dirty_gem.coal', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.cobalt'), utils.get('jaopca:skyresources_dirty_gem.cobalt', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.copper'), utils.get('jaopca:skyresources_dirty_gem.copper', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.diamond'), utils.get('jaopca:skyresources_dirty_gem.diamond', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.dilithium'), utils.get('jaopca:skyresources_dirty_gem.dilithium', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.dimensionalshard'), utils.get('jaopca:skyresources_dirty_gem.dimensionalshard', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.draconium'), utils.get('jaopca:skyresources_dirty_gem.draconium', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.emerald'), utils.get('jaopca:skyresources_dirty_gem.emerald', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.gold'), utils.get('jaopca:skyresources_dirty_gem.gold', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.iridium'), utils.get('jaopca:skyresources_dirty_gem.iridium', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.iron'), utils.get('jaopca:skyresources_dirty_gem.iron', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.lapis'), utils.get('jaopca:skyresources_dirty_gem.lapis', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.lead'), utils.get('jaopca:skyresources_dirty_gem.lead', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.lithium'), utils.get('jaopca:skyresources_dirty_gem.lithium', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.magnesium'), utils.get('jaopca:skyresources_dirty_gem.magnesium', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.malachite'), utils.get('jaopca:skyresources_dirty_gem.malachite', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.mithril'), utils.get('jaopca:skyresources_dirty_gem.mithril', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.nickel'), utils.get('jaopca:skyresources_dirty_gem.nickel', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.osmium'), utils.get('jaopca:skyresources_dirty_gem.osmium', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.peridot'), utils.get('jaopca:skyresources_dirty_gem.peridot', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.platinum'), utils.get('jaopca:skyresources_dirty_gem.platinum', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.quartz'), utils.get('jaopca:skyresources_dirty_gem.quartz', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.quartzblack'), utils.get('jaopca:skyresources_dirty_gem.quartzblack', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.redstone'), utils.get('jaopca:skyresources_dirty_gem.redstone', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.ruby'), utils.get('jaopca:skyresources_dirty_gem.ruby', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.sapphire'), utils.get('jaopca:skyresources_dirty_gem.sapphire', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.silver'), utils.get('jaopca:skyresources_dirty_gem.silver', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.tanzanite'), utils.get('jaopca:skyresources_dirty_gem.tanzanite', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.thorium'), utils.get('jaopca:skyresources_dirty_gem.thorium', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.tin'), utils.get('jaopca:skyresources_dirty_gem.tin', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.titanium'), utils.get('jaopca:skyresources_dirty_gem.titanium', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.topaz'), utils.get('jaopca:skyresources_dirty_gem.topaz', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.trinitite'), utils.get('jaopca:skyresources_dirty_gem.trinitite', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.tungsten'), utils.get('jaopca:skyresources_dirty_gem.tungsten', 0, 10));
infinFurnace(utils.get('jaopca:magneticraft_chunk.uranium'), utils.get('jaopca:skyresources_dirty_gem.uranium', 0, 10));
infinFurnace(utils.get('jaopca:thaumcraft_cluster.aluminium'), utils.get('thermalfoundation:material', 132, 2));
infinFurnace(utils.get('jaopca:thaumcraft_cluster.amber'), utils.get('thaumcraft:amber', 0, 3));
infinFurnace(utils.get('jaopca:thaumcraft_cluster.amethyst'), utils.get('biomesoplenty:gem', 0, 3));
infinFurnace(utils.get('jaopca:thaumcraft_cluster.anglesite'), utils.get('contenttweaker:anglesite', 0, 2));
infinFurnace(utils.get('jaopca:thaumcraft_cluster.apatite'), utils.get('forestry:apatite', 0, 17));
infinFurnace(utils.get('jaopca:thaumcraft_cluster.aquamarine'), utils.get('astralsorcery:itemcraftingcomponent', 0, 7));
infinFurnace(utils.get('jaopca:thaumcraft_cluster.ardite'), utils.get('tconstruct:ingots', 1, 2));
infinFurnace(utils.get('jaopca:thaumcraft_cluster.astralstarmetal'), utils.get('astralsorcery:itemcraftingcomponent', 1, 2));
infinFurnace(utils.get('jaopca:thaumcraft_cluster.benitoite'), utils.get('contenttweaker:benitoite', 0, 2));
infinFurnace(utils.get('jaopca:thaumcraft_cluster.boron'), utils.get('nuclearcraft:ingot', 5, 2));
infinFurnace(utils.get('jaopca:thaumcraft_cluster.certusquartz'), utils.get('appliedenergistics2:material', 0, 5));
infinFurnace(utils.get('jaopca:thaumcraft_cluster.chargedcertusquartz'), utils.get('appliedenergistics2:material', 1, 3));
infinFurnace(utils.get('jaopca:thaumcraft_cluster.coal'), utils.get('minecraft:coal', 0, 8));
infinFurnace(utils.get('jaopca:thaumcraft_cluster.cobalt'), utils.get('tconstruct:ingots', 0, 2));
infinFurnace(utils.get('jaopca:thaumcraft_cluster.diamond'), utils.get('minecraft:diamond', 0, 3));
infinFurnace(utils.get('jaopca:thaumcraft_cluster.dilithium'), utils.get('libvulpes:productgem', 0, 2));
infinFurnace(utils.get('jaopca:thaumcraft_cluster.dimensionalshard'), utils.get('rftools:dimensional_shard', 0, 5));
infinFurnace(utils.get('jaopca:thaumcraft_cluster.draconium'), utils.get('draconicevolution:draconium_ingot', 0, 2));
infinFurnace(utils.get('jaopca:thaumcraft_cluster.emerald'), utils.get('minecraft:emerald', 0, 3));
infinFurnace(utils.get('jaopca:thaumcraft_cluster.iridium'), utils.get('thermalfoundation:material', 135, 2));
infinFurnace(utils.get('jaopca:thaumcraft_cluster.lapis'), utils.get('minecraft:dye', 4, 17));
infinFurnace(utils.get('jaopca:thaumcraft_cluster.lithium'), utils.get('nuclearcraft:ingot', 6, 2));
infinFurnace(utils.get('jaopca:thaumcraft_cluster.magnesium'), utils.get('nuclearcraft:ingot', 7, 2));
infinFurnace(utils.get('jaopca:thaumcraft_cluster.malachite'), utils.get('biomesoplenty:gem', 5, 3));
infinFurnace(utils.get('jaopca:thaumcraft_cluster.mithril'), utils.get('thermalfoundation:material', 136, 2));
infinFurnace(utils.get('jaopca:thaumcraft_cluster.nickel'), utils.get('thermalfoundation:material', 133, 2));
infinFurnace(utils.get('jaopca:thaumcraft_cluster.osmium'), utils.get('mekanism:ingot', 1, 2));
infinFurnace(utils.get('jaopca:thaumcraft_cluster.peridot'), utils.get('biomesoplenty:gem', 2, 3));
infinFurnace(utils.get('jaopca:thaumcraft_cluster.platinum'), utils.get('thermalfoundation:material', 134, 2));
infinFurnace(utils.get('jaopca:thaumcraft_cluster.quartzblack'), utils.get('actuallyadditions:item_misc', 5, 3));
infinFurnace(utils.get('jaopca:thaumcraft_cluster.redstone'), utils.get('extrautils2:ingredients', 0, 17));
infinFurnace(utils.get('jaopca:thaumcraft_cluster.ruby'), utils.get('biomesoplenty:gem', 1, 3));
infinFurnace(utils.get('jaopca:thaumcraft_cluster.sapphire'), utils.get('biomesoplenty:gem', 6, 3));
infinFurnace(utils.get('jaopca:thaumcraft_cluster.tanzanite'), utils.get('biomesoplenty:gem', 4, 3));
infinFurnace(utils.get('jaopca:thaumcraft_cluster.thorium'), utils.get('nuclearcraft:ingot', 3, 2));
infinFurnace(utils.get('jaopca:thaumcraft_cluster.titanium'), utils.get('libvulpes:productingot', 7, 2));
infinFurnace(utils.get('jaopca:thaumcraft_cluster.topaz'), utils.get('biomesoplenty:gem', 3, 3));
infinFurnace(utils.get('jaopca:thaumcraft_cluster.trinitite'), utils.get('trinity:trinitite_shard', 0, 2));
infinFurnace(utils.get('jaopca:thaumcraft_cluster.tungsten'), utils.get('qmd:dust', 0, 2));
infinFurnace(utils.get('jaopca:thaumcraft_cluster.uranium'), utils.get('immersiveengineering:metal', 5, 2));
infinFurnace(utils.get('jaopca:ic2_crushed.aluminium'), utils.get('thermalfoundation:material', 132));
infinFurnace(utils.get('jaopca:ic2_crushed.ardite'), utils.get('tconstruct:ingots', 1));
infinFurnace(utils.get('jaopca:ic2_crushed.astralstarmetal'), utils.get('astralsorcery:itemcraftingcomponent', 1));
infinFurnace(utils.get('jaopca:ic2_crushed.boron'), utils.get('nuclearcraft:ingot', 5));
infinFurnace(utils.get('jaopca:ic2_crushed.cobalt'), utils.get('tconstruct:ingots'));
infinFurnace(utils.get('jaopca:ic2_crushed.draconium'), utils.get('draconicevolution:draconium_ingot'));
infinFurnace(utils.get('jaopca:ic2_crushed.iridium'), utils.get('thermalfoundation:material', 135));
infinFurnace(utils.get('jaopca:ic2_crushed.lithium'), utils.get('nuclearcraft:ingot', 6));
infinFurnace(utils.get('jaopca:ic2_crushed.magnesium'), utils.get('nuclearcraft:ingot', 7));
infinFurnace(utils.get('jaopca:ic2_crushed.mithril'), utils.get('thermalfoundation:material', 136));
infinFurnace(utils.get('jaopca:ic2_crushed.nickel'), utils.get('thermalfoundation:material', 133));
infinFurnace(utils.get('jaopca:ic2_crushed.osmium'), utils.get('mekanism:ingot', 1));
infinFurnace(utils.get('jaopca:ic2_crushed.platinum'), utils.get('thermalfoundation:material', 134));
infinFurnace(utils.get('jaopca:ic2_crushed.purifiedaluminium'), utils.get('thermalfoundation:material', 132));
infinFurnace(utils.get('jaopca:ic2_crushed.purifiedardite'), utils.get('tconstruct:ingots', 1));
infinFurnace(utils.get('jaopca:ic2_crushed.purifiedastralstarmetal'), utils.get('astralsorcery:itemcraftingcomponent', 1));
infinFurnace(utils.get('jaopca:ic2_crushed.purifiedboron'), utils.get('nuclearcraft:ingot', 5));
infinFurnace(utils.get('jaopca:ic2_crushed.purifiedcobalt'), utils.get('tconstruct:ingots'));
infinFurnace(utils.get('jaopca:ic2_crushed.purifieddraconium'), utils.get('draconicevolution:draconium_ingot'));
infinFurnace(utils.get('jaopca:ic2_crushed.purifiediridium'), utils.get('thermalfoundation:material', 135));
infinFurnace(utils.get('jaopca:ic2_crushed.purifiedlithium'), utils.get('nuclearcraft:ingot', 6));
infinFurnace(utils.get('jaopca:ic2_crushed.purifiedmagnesium'), utils.get('nuclearcraft:ingot', 7));
infinFurnace(utils.get('jaopca:ic2_crushed.purifiedmithril'), utils.get('thermalfoundation:material', 136));
infinFurnace(utils.get('jaopca:ic2_crushed.purifiednickel'), utils.get('thermalfoundation:material', 133));
infinFurnace(utils.get('jaopca:ic2_crushed.purifiedosmium'), utils.get('mekanism:ingot', 1));
infinFurnace(utils.get('jaopca:ic2_crushed.purifiedplatinum'), utils.get('thermalfoundation:material', 134));
infinFurnace(utils.get('jaopca:ic2_crushed.purifiedthorium'), utils.get('nuclearcraft:ingot', 3));
infinFurnace(utils.get('jaopca:ic2_crushed.purifiedtungsten'), utils.get('endreborn:item_ingot_wolframium'));
infinFurnace(utils.get('jaopca:ic2_crushed.thorium'), utils.get('nuclearcraft:ingot', 3));
infinFurnace(utils.get('jaopca:ic2_crushed.tungsten'), utils.get('endreborn:item_ingot_wolframium'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abyssaluminium'), utils.get('jaopca:skyresources_dirty_gem.aluminium'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abyssamber'), utils.get('jaopca:skyresources_dirty_gem.amber'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abyssamethyst'), utils.get('jaopca:skyresources_dirty_gem.amethyst'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abyssanglesite'), utils.get('jaopca:skyresources_dirty_gem.anglesite'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abyssapatite'), utils.get('jaopca:skyresources_dirty_gem.apatite'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abyssaquamarine'), utils.get('jaopca:skyresources_dirty_gem.aquamarine'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abyssardite'), utils.get('jaopca:skyresources_dirty_gem.ardite'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abyssastralstarmetal'), utils.get('jaopca:skyresources_dirty_gem.astralstarmetal'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abyssbenitoite'), utils.get('jaopca:skyresources_dirty_gem.benitoite'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abyssboron'), utils.get('jaopca:skyresources_dirty_gem.boron'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abysscertusquartz'), utils.get('jaopca:skyresources_dirty_gem.certusquartz'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abysschargedcertusquartz'), utils.get('jaopca:skyresources_dirty_gem.chargedcertusquartz'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abysscoal'), utils.get('jaopca:skyresources_dirty_gem.coal'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abysscobalt'), utils.get('jaopca:skyresources_dirty_gem.cobalt'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abysscopper'), utils.get('jaopca:skyresources_dirty_gem.copper'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abyssdiamond'), utils.get('jaopca:skyresources_dirty_gem.diamond'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abyssdilithium'), utils.get('jaopca:skyresources_dirty_gem.dilithium'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abyssdimensionalshard'), utils.get('jaopca:skyresources_dirty_gem.dimensionalshard'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abyssdraconium'), utils.get('jaopca:skyresources_dirty_gem.draconium'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abyssemerald'), utils.get('jaopca:skyresources_dirty_gem.emerald'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abyssgold'), utils.get('jaopca:skyresources_dirty_gem.gold'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abyssiridium'), utils.get('jaopca:skyresources_dirty_gem.iridium'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abyssiron'), utils.get('jaopca:skyresources_dirty_gem.iron'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abysslapis'), utils.get('jaopca:skyresources_dirty_gem.lapis'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abysslead'), utils.get('jaopca:skyresources_dirty_gem.lead'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abysslithium'), utils.get('jaopca:skyresources_dirty_gem.lithium'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abyssmagnesium'), utils.get('jaopca:skyresources_dirty_gem.magnesium'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abyssmalachite'), utils.get('jaopca:skyresources_dirty_gem.malachite'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abyssmithril'), utils.get('jaopca:skyresources_dirty_gem.mithril'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abyssnickel'), utils.get('jaopca:skyresources_dirty_gem.nickel'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abyssosmium'), utils.get('jaopca:skyresources_dirty_gem.osmium'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abyssperidot'), utils.get('jaopca:skyresources_dirty_gem.peridot'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abyssplatinum'), utils.get('jaopca:skyresources_dirty_gem.platinum'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abyssquartz'), utils.get('jaopca:skyresources_dirty_gem.quartz'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abyssquartzblack'), utils.get('jaopca:skyresources_dirty_gem.quartzblack'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abyssredstone'), utils.get('jaopca:skyresources_dirty_gem.redstone'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abyssruby'), utils.get('jaopca:skyresources_dirty_gem.ruby'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abysssapphire'), utils.get('jaopca:skyresources_dirty_gem.sapphire'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abysssilver'), utils.get('jaopca:skyresources_dirty_gem.silver'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abysstanzanite'), utils.get('jaopca:skyresources_dirty_gem.tanzanite'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abyssthorium'), utils.get('jaopca:skyresources_dirty_gem.thorium'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abysstin'), utils.get('jaopca:skyresources_dirty_gem.tin'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abysstitanium'), utils.get('jaopca:skyresources_dirty_gem.titanium'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abysstopaz'), utils.get('jaopca:skyresources_dirty_gem.topaz'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abysstrinitite'), utils.get('jaopca:skyresources_dirty_gem.trinitite'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abysstungsten'), utils.get('jaopca:skyresources_dirty_gem.tungsten'));
infinFurnace(utils.get('jaopca:mekanism_crystal.abyssuranium'), utils.get('jaopca:skyresources_dirty_gem.uranium'));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.aluminium'), utils.get('thermalfoundation:material', 132, 12));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.amber'), utils.get('thaumcraft:amber', 0, 18));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.amethyst'), utils.get('biomesoplenty:gem', 0, 18));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.anglesite'), utils.get('contenttweaker:anglesite', 0, 12));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.apatite'), utils.get('forestry:apatite', 0, 64));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.aquamarine'), utils.get('astralsorcery:itemcraftingcomponent', 0, 37));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.ardite'), utils.get('tconstruct:ingots', 1, 12));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.astralstarmetal'), utils.get('astralsorcery:itemcraftingcomponent', 1, 12));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.benitoite'), utils.get('contenttweaker:benitoite', 0, 12));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.boron'), utils.get('nuclearcraft:ingot', 5, 12));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.certusquartz'), utils.get('appliedenergistics2:material', 0, 27));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.chargedcertusquartz'), utils.get('appliedenergistics2:material', 1, 18));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.coal'), utils.get('minecraft:coal', 0, 46));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.cobalt'), utils.get('tconstruct:ingots', 0, 12));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.copper'), utils.get('thermalfoundation:material', 128, 12));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.diamond'), utils.get('minecraft:diamond', 0, 18));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.dilithium'), utils.get('libvulpes:productgem', 0, 12));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.dimensionalshard'), utils.get('rftools:dimensional_shard', 0, 27));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.draconium'), utils.get('draconicevolution:draconium_ingot', 0, 12));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.emerald'), utils.get('minecraft:emerald', 0, 18));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.gold'), utils.get('minecraft:gold_ingot', 0, 12));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.iridium'), utils.get('thermalfoundation:material', 135, 12));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.iron'), utils.get('minecraft:iron_ingot', 0, 12));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.lapis'), utils.get('minecraft:dye', 4, 64));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.lead'), utils.get('thermalfoundation:material', 131, 12));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.lithium'), utils.get('nuclearcraft:ingot', 6, 12));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.magnesium'), utils.get('nuclearcraft:ingot', 7, 12));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.malachite'), utils.get('biomesoplenty:gem', 5, 18));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.mithril'), utils.get('thermalfoundation:material', 136, 12));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.nickel'), utils.get('thermalfoundation:material', 133, 12));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.osmium'), utils.get('mekanism:ingot', 1, 12));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.peridot'), utils.get('biomesoplenty:gem', 2, 18));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.platinum'), utils.get('thermalfoundation:material', 134, 12));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.quartz'), utils.get('minecraft:quartz', 0, 27));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.quartzblack'), utils.get('actuallyadditions:item_misc', 5, 18));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.redstone'), utils.get('extrautils2:ingredients', 0, 64));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.ruby'), utils.get('biomesoplenty:gem', 1, 18));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.sapphire'), utils.get('biomesoplenty:gem', 6, 18));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.silver'), utils.get('thermalfoundation:material', 130, 12));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.tanzanite'), utils.get('biomesoplenty:gem', 4, 18));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.thorium'), utils.get('nuclearcraft:ingot', 3, 12));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.tin'), utils.get('thermalfoundation:material', 129, 12));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.titanium'), utils.get('libvulpes:productingot', 7, 12));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.topaz'), utils.get('biomesoplenty:gem', 3, 18));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.trinitite'), utils.get('trinity:trinitite_shard', 0, 12));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.tungsten'), utils.get('qmd:dust', 0, 12));
infinFurnace(utils.get('jaopca:skyresources_dirty_gem.uranium'), utils.get('immersiveengineering:metal', 5, 12));
infinFurnace(utils.get('jaopca:dust.alchaluminium'), utils.get('jaopca:skyresources_dirty_gem.aluminium', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchamber'), utils.get('jaopca:skyresources_dirty_gem.amber', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchamethyst'), utils.get('jaopca:skyresources_dirty_gem.amethyst', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchanglesite'), utils.get('jaopca:skyresources_dirty_gem.anglesite', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchapatite'), utils.get('jaopca:skyresources_dirty_gem.apatite', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchaquamarine'), utils.get('jaopca:skyresources_dirty_gem.aquamarine', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchardite'), utils.get('jaopca:skyresources_dirty_gem.ardite', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchastralstarmetal'), utils.get('jaopca:skyresources_dirty_gem.astralstarmetal', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchbenitoite'), utils.get('jaopca:skyresources_dirty_gem.benitoite', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchboron'), utils.get('jaopca:skyresources_dirty_gem.boron', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchcertusquartz'), utils.get('jaopca:skyresources_dirty_gem.certusquartz', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchchargedcertusquartz'), utils.get('jaopca:skyresources_dirty_gem.chargedcertusquartz', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchcoal'), utils.get('jaopca:skyresources_dirty_gem.coal', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchcobalt'), utils.get('jaopca:skyresources_dirty_gem.cobalt', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchcopper'), utils.get('jaopca:skyresources_dirty_gem.copper', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchdiamond'), utils.get('jaopca:skyresources_dirty_gem.diamond', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchdilithium'), utils.get('jaopca:skyresources_dirty_gem.dilithium', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchdimensionalshard'), utils.get('jaopca:skyresources_dirty_gem.dimensionalshard', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchdraconium'), utils.get('jaopca:skyresources_dirty_gem.draconium', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchemerald'), utils.get('jaopca:skyresources_dirty_gem.emerald', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchgold'), utils.get('jaopca:skyresources_dirty_gem.gold', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchiridium'), utils.get('jaopca:skyresources_dirty_gem.iridium', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchiron'), utils.get('jaopca:skyresources_dirty_gem.iron', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchlapis'), utils.get('jaopca:skyresources_dirty_gem.lapis', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchlead'), utils.get('jaopca:skyresources_dirty_gem.lead', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchlithium'), utils.get('jaopca:skyresources_dirty_gem.lithium', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchmagnesium'), utils.get('jaopca:skyresources_dirty_gem.magnesium', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchmalachite'), utils.get('jaopca:skyresources_dirty_gem.malachite', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchmithril'), utils.get('jaopca:skyresources_dirty_gem.mithril', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchnickel'), utils.get('jaopca:skyresources_dirty_gem.nickel', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchosmium'), utils.get('jaopca:skyresources_dirty_gem.osmium', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchperidot'), utils.get('jaopca:skyresources_dirty_gem.peridot', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchplatinum'), utils.get('jaopca:skyresources_dirty_gem.platinum', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchquartz'), utils.get('jaopca:skyresources_dirty_gem.quartz', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchquartzblack'), utils.get('jaopca:skyresources_dirty_gem.quartzblack', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchredstone'), utils.get('jaopca:skyresources_dirty_gem.redstone', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchruby'), utils.get('jaopca:skyresources_dirty_gem.ruby', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchsapphire'), utils.get('jaopca:skyresources_dirty_gem.sapphire', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchsilver'), utils.get('jaopca:skyresources_dirty_gem.silver', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchtanzanite'), utils.get('jaopca:skyresources_dirty_gem.tanzanite', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchthorium'), utils.get('jaopca:skyresources_dirty_gem.thorium', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchtin'), utils.get('jaopca:skyresources_dirty_gem.tin', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchtitanium'), utils.get('jaopca:skyresources_dirty_gem.titanium', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchtopaz'), utils.get('jaopca:skyresources_dirty_gem.topaz', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchtrinitite'), utils.get('jaopca:skyresources_dirty_gem.trinitite', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchtungsten'), utils.get('jaopca:skyresources_dirty_gem.tungsten', 0, 48));
infinFurnace(utils.get('jaopca:dust.alchuranium'), utils.get('jaopca:skyresources_dirty_gem.uranium', 0, 48));
blacklist('jaopca:dust.amber');
blacklist('jaopca:dust.amethyst');
blacklist('jaopca:dust.apatite');
blacklist('jaopca:dust.aquamarine');
blacklist('jaopca:dust.chargedcertusquartz');
blacklist('jaopca:dust.malachite');
blacklist('jaopca:dust.peridot');
blacklist('jaopca:dust.ruby');
blacklist('jaopca:dust.sapphire');
blacklist('jaopca:dust.tanzanite');
blacklist('jaopca:dust.topaz');
blacklist('jaopca:dust.trinitite');
blacklist('jaopca:exnihilocreatio_chunk.astralstarmetal');
blacklist('jaopca:exnihilocreatio_chunk.draconium');
blacklist('jaopca:exnihilocreatio_chunk.iridium');
blacklist('jaopca:exnihilocreatio_chunk.mithril');
blacklist('jaopca:exnihilocreatio_chunk.osmium');
blacklist('jaopca:exnihilocreatio_chunk.platinum');
blacklist('jaopca:exnihilocreatio_chunk.titanium');
blacklist('jaopca:exnihilocreatio_chunk.tungsten');
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.aluminium'), utils.get('jaopca:skyresources_dirty_gem.aluminium', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.amber'), utils.get('jaopca:skyresources_dirty_gem.amber', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.amethyst'), utils.get('jaopca:skyresources_dirty_gem.amethyst', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.anglesite'), utils.get('jaopca:skyresources_dirty_gem.anglesite', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.apatite'), utils.get('jaopca:skyresources_dirty_gem.apatite', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.aquamarine'), utils.get('jaopca:skyresources_dirty_gem.aquamarine', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.ardite'), utils.get('jaopca:skyresources_dirty_gem.ardite', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.astralstarmetal'), utils.get('jaopca:skyresources_dirty_gem.astralstarmetal', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.benitoite'), utils.get('jaopca:skyresources_dirty_gem.benitoite', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.boron'), utils.get('jaopca:skyresources_dirty_gem.boron', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.certusquartz'), utils.get('jaopca:skyresources_dirty_gem.certusquartz', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.chargedcertusquartz'), utils.get('jaopca:skyresources_dirty_gem.chargedcertusquartz', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.coal'), utils.get('jaopca:skyresources_dirty_gem.coal', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.cobalt'), utils.get('jaopca:skyresources_dirty_gem.cobalt', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.copper'), utils.get('jaopca:skyresources_dirty_gem.copper', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.diamond'), utils.get('jaopca:skyresources_dirty_gem.diamond', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.dilithium'), utils.get('jaopca:skyresources_dirty_gem.dilithium', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.dimensionalshard'), utils.get('jaopca:skyresources_dirty_gem.dimensionalshard', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.draconium'), utils.get('jaopca:skyresources_dirty_gem.draconium', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.emerald'), utils.get('jaopca:skyresources_dirty_gem.emerald', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.gold'), utils.get('jaopca:skyresources_dirty_gem.gold', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.iridium'), utils.get('jaopca:skyresources_dirty_gem.iridium', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.iron'), utils.get('jaopca:skyresources_dirty_gem.iron', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.lapis'), utils.get('jaopca:skyresources_dirty_gem.lapis', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.lead'), utils.get('jaopca:skyresources_dirty_gem.lead', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.lithium'), utils.get('jaopca:skyresources_dirty_gem.lithium', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.magnesium'), utils.get('jaopca:skyresources_dirty_gem.magnesium', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.malachite'), utils.get('jaopca:skyresources_dirty_gem.malachite', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.mithril'), utils.get('jaopca:skyresources_dirty_gem.mithril', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.nickel'), utils.get('jaopca:skyresources_dirty_gem.nickel', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.osmium'), utils.get('jaopca:skyresources_dirty_gem.osmium', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.peridot'), utils.get('jaopca:skyresources_dirty_gem.peridot', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.platinum'), utils.get('jaopca:skyresources_dirty_gem.platinum', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.quartz'), utils.get('jaopca:skyresources_dirty_gem.quartz', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.quartzblack'), utils.get('jaopca:skyresources_dirty_gem.quartzblack', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.redstone'), utils.get('jaopca:skyresources_dirty_gem.redstone', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.ruby'), utils.get('jaopca:skyresources_dirty_gem.ruby', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.sapphire'), utils.get('jaopca:skyresources_dirty_gem.sapphire', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.silver'), utils.get('jaopca:skyresources_dirty_gem.silver', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.tanzanite'), utils.get('jaopca:skyresources_dirty_gem.tanzanite', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.thorium'), utils.get('jaopca:skyresources_dirty_gem.thorium', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.tin'), utils.get('jaopca:skyresources_dirty_gem.tin', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.titanium'), utils.get('jaopca:skyresources_dirty_gem.titanium', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.topaz'), utils.get('jaopca:skyresources_dirty_gem.topaz', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.trinitite'), utils.get('jaopca:skyresources_dirty_gem.trinitite', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.tungsten'), utils.get('jaopca:skyresources_dirty_gem.tungsten', 0, 4));
infinFurnace(utils.get('jaopca:magneticraft_rocky_chunk.uranium'), utils.get('jaopca:skyresources_dirty_gem.uranium', 0, 4));
infinFurnace(utils.get('libvulpes:ore0'), utils.get('libvulpes:productdust'));
blacklist('libvulpes:productdust', 3);
blacklist('libvulpes:productdust', 7);
infinFurnace(utils.get('mechanics:heavy_mesh', W), utils.get('mechanics:heavy_ingot', 0, 2));
blacklist('mekanism:dust', 1);
blacklist('mekanism:dust', 2);
blacklist('mekanism:dust', 3);
blacklist('mekanism:dust', 4);
blacklist('mekanism:dust');
infinFurnace(utils.get('mekanism:oreblock'), utils.get('mekanism:ingot', 1));
blacklist('mekanism:otherdust', 1);
blacklist('mekanism:otherdust', 4);
infinFurnace(utils.get('mekanism:polyethene', 1), utils.get('rats:rat_tube_white'));
infinFurnace(utils.get('minecraft:beef', W), utils.get('minecraft:cooked_beef'));
infinFurnace(utils.get('minecraft:book', W), utils.get('cookingforblockheads:recipe_book', 1));
infinFurnace(utils.get('minecraft:cactus', W), utils.get('minecraft:dye', 2));
infinFurnace(utils.get('minecraft:chainmail_boots', W), utils.get('minecraft:iron_nugget'));
infinFurnace(utils.get('minecraft:chainmail_chestplate', W), utils.get('minecraft:iron_nugget'));
infinFurnace(utils.get('minecraft:chainmail_helmet', W), utils.get('minecraft:iron_nugget'));
infinFurnace(utils.get('minecraft:chainmail_leggings', W), utils.get('minecraft:iron_nugget'));
infinFurnace(utils.get('minecraft:chicken', W), utils.get('minecraft:cooked_chicken'));
infinFurnace(utils.get('minecraft:chorus_fruit', W), utils.get('minecraft:chorus_fruit_popped'));
infinFurnace(utils.get('minecraft:clay_ball', W), utils.get('minecraft:brick'));
infinFurnace(utils.get('minecraft:clay', W), utils.get('minecraft:hardened_clay'));
infinFurnace(utils.get('minecraft:coal_ore', W), utils.get('minecraft:coal'));
infinFurnace(utils.get('minecraft:coal', W), utils.get('nuclearcraft:ingot', 8));
infinFurnace(utils.get('minecraft:cobblestone', W), utils.get('minecraft:stone'));
infinFurnace(utils.get('minecraft:diamond_ore', W), utils.get('minecraft:diamond'));
infinFurnace(utils.get('minecraft:dye', 3), utils.get('nuclearcraft:roasted_cocoa_beans'));
infinFurnace(utils.get('minecraft:egg'), utils.get('betteranimalsplus:fried_egg'));
infinFurnace(utils.get('minecraft:emerald_ore', W), utils.get('minecraft:emerald'));
infinFurnace(utils.get('minecraft:fish', 1), utils.get('minecraft:cooked_fish', 1));
infinFurnace(utils.get('minecraft:fish'), utils.get('minecraft:cooked_fish'));
infinFurnace(utils.get('minecraft:gold_ore', W), utils.get('minecraft:gold_ingot'));
infinFurnace(utils.get('minecraft:golden_axe', W), utils.get('minecraft:gold_nugget'));
infinFurnace(utils.get('minecraft:golden_boots', W), utils.get('minecraft:gold_nugget'));
infinFurnace(utils.get('minecraft:golden_chestplate', W), utils.get('minecraft:gold_nugget'));
infinFurnace(utils.get('minecraft:golden_helmet', W), utils.get('minecraft:gold_nugget'));
infinFurnace(utils.get('minecraft:golden_hoe', W), utils.get('minecraft:gold_nugget'));
infinFurnace(utils.get('minecraft:golden_horse_armor', W), utils.get('minecraft:gold_nugget'));
infinFurnace(utils.get('minecraft:golden_leggings', W), utils.get('minecraft:gold_nugget'));
infinFurnace(utils.get('minecraft:golden_pickaxe', W), utils.get('minecraft:gold_nugget'));
infinFurnace(utils.get('minecraft:golden_shovel', W), utils.get('minecraft:gold_nugget'));
infinFurnace(utils.get('minecraft:golden_sword', W), utils.get('minecraft:gold_nugget'));
infinFurnace(utils.get('minecraft:iron_axe', W), utils.get('minecraft:iron_nugget'));
infinFurnace(utils.get('minecraft:iron_boots', W), utils.get('minecraft:iron_nugget'));
infinFurnace(utils.get('minecraft:iron_chestplate', W), utils.get('minecraft:iron_nugget'));
infinFurnace(utils.get('minecraft:iron_helmet', W), utils.get('minecraft:iron_nugget'));
infinFurnace(utils.get('minecraft:iron_hoe', W), utils.get('minecraft:iron_nugget'));
infinFurnace(utils.get('minecraft:iron_horse_armor', W), utils.get('minecraft:iron_nugget'));
infinFurnace(utils.get('minecraft:iron_leggings', W), utils.get('minecraft:iron_nugget'));
infinFurnace(utils.get('minecraft:iron_ore', W), utils.get('minecraft:iron_ingot'));
infinFurnace(utils.get('minecraft:iron_pickaxe', W), utils.get('minecraft:iron_nugget'));
infinFurnace(utils.get('minecraft:iron_shovel', W), utils.get('minecraft:iron_nugget'));
infinFurnace(utils.get('minecraft:iron_sword', W), utils.get('minecraft:iron_nugget'));
infinFurnace(utils.get('minecraft:lapis_ore', W), utils.get('minecraft:dye', 4));
// SKIP: 'minecraft:log', W
// SKIP: 'minecraft:log2', W
infinFurnace(utils.get('minecraft:mutton', W), utils.get('minecraft:cooked_mutton'));
infinFurnace(utils.get('minecraft:netherrack', W), utils.get('minecraft:netherbrick'));
infinFurnace(utils.get('minecraft:porkchop', W), utils.get('minecraft:cooked_porkchop'));
infinFurnace(utils.get('minecraft:potato', W), utils.get('minecraft:baked_potato'));
infinFurnace(utils.get('minecraft:quartz_ore', W), utils.get('minecraft:quartz'));
infinFurnace(utils.get('minecraft:rabbit', W), utils.get('minecraft:cooked_rabbit'));
infinFurnace(utils.get('minecraft:redstone_ore', W), utils.get('minecraft:redstone'));
infinFurnace(utils.get('minecraft:rotten_flesh'), utils.get('rustic:tallow'));
infinFurnace(utils.get('minecraft:sand', W), utils.get('minecraft:glass'));
blacklist('minecraft:sponge', 1);
infinFurnace(utils.get('minecraft:stained_hardened_clay', 1), utils.get('minecraft:orange_glazed_terracotta'));
infinFurnace(utils.get('minecraft:stained_hardened_clay', 2), utils.get('minecraft:magenta_glazed_terracotta'));
infinFurnace(utils.get('minecraft:stained_hardened_clay', 3), utils.get('minecraft:light_blue_glazed_terracotta'));
infinFurnace(utils.get('minecraft:stained_hardened_clay', 4), utils.get('minecraft:yellow_glazed_terracotta'));
infinFurnace(utils.get('minecraft:stained_hardened_clay', 5), utils.get('minecraft:lime_glazed_terracotta'));
infinFurnace(utils.get('minecraft:stained_hardened_clay', 6), utils.get('minecraft:pink_glazed_terracotta'));
infinFurnace(utils.get('minecraft:stained_hardened_clay', 7), utils.get('minecraft:gray_glazed_terracotta'));
infinFurnace(utils.get('minecraft:stained_hardened_clay', 8), utils.get('minecraft:silver_glazed_terracotta'));
infinFurnace(utils.get('minecraft:stained_hardened_clay', 9), utils.get('minecraft:cyan_glazed_terracotta'));
infinFurnace(utils.get('minecraft:stained_hardened_clay', 10), utils.get('minecraft:purple_glazed_terracotta'));
infinFurnace(utils.get('minecraft:stained_hardened_clay', 11), utils.get('minecraft:blue_glazed_terracotta'));
infinFurnace(utils.get('minecraft:stained_hardened_clay', 12), utils.get('minecraft:brown_glazed_terracotta'));
infinFurnace(utils.get('minecraft:stained_hardened_clay', 13), utils.get('minecraft:green_glazed_terracotta'));
infinFurnace(utils.get('minecraft:stained_hardened_clay', 14), utils.get('minecraft:red_glazed_terracotta'));
infinFurnace(utils.get('minecraft:stained_hardened_clay', 15), utils.get('minecraft:black_glazed_terracotta'));
infinFurnace(utils.get('minecraft:stained_hardened_clay'), utils.get('minecraft:white_glazed_terracotta'));
blacklist('minecraft:stonebrick');
infinFurnace(utils.get('mysticalagriculture:crafting', 29), utils.get('mysticalagriculture:crafting', 38));
blacklist('mysticalagriculture:soulstone', 1);
infinFurnace(utils.get('mysticalagriculture:soulstone', 3), utils.get('mysticalagriculture:soulstone', 4));
infinFurnace(utils.get('mysticalagriculture:soulstone'), utils.get('mysticalagriculture:crafting', 28));
infinFurnace(utils.get('netherendingores:ore_end_modded_1', 1), utils.get('thermalfoundation:ore', 0, 2));
blacklist('netherendingores:ore_end_modded_1', 2);
infinFurnace(utils.get('netherendingores:ore_end_modded_1', 3), utils.get('thermalfoundation:ore', 3, 2));
infinFurnace(utils.get('netherendingores:ore_end_modded_1', 4), utils.get('thermalfoundation:ore', 8, 2));
infinFurnace(utils.get('netherendingores:ore_end_modded_1', 5), utils.get('thermalfoundation:ore', 5, 2));
infinFurnace(utils.get('netherendingores:ore_end_modded_1', 6), utils.get('thermalfoundation:ore', 6, 2));
infinFurnace(utils.get('netherendingores:ore_end_modded_1', 7), utils.get('thermalfoundation:ore', 2, 2));
infinFurnace(utils.get('netherendingores:ore_end_modded_1', 8), utils.get('thermalfoundation:ore', 1, 2));
infinFurnace(utils.get('netherendingores:ore_end_modded_1', 9), utils.get('appliedenergistics2:quartz_ore', 0, 2));
blacklist('netherendingores:ore_end_modded_1', 10);
infinFurnace(utils.get('netherendingores:ore_end_modded_1', 11), utils.get('mekanism:oreblock', 0, 2));
infinFurnace(utils.get('netherendingores:ore_end_modded_1', 12), utils.get('immersiveengineering:ore', 5, 2));
infinFurnace(utils.get('netherendingores:ore_end_modded_1', 14), utils.get('libvulpes:ore0', 0, 2));
infinFurnace(utils.get('netherendingores:ore_end_modded_1'), utils.get('thermalfoundation:ore', 4, 2));
infinFurnace(utils.get('netherendingores:ore_end_modded_2', 1), utils.get('biomesoplenty:gem_ore', 1, 2));
infinFurnace(utils.get('netherendingores:ore_end_modded_2', 2), utils.get('biomesoplenty:gem_ore', 6, 2));
blacklist('netherendingores:ore_end_modded_2', 3);
blacklist('netherendingores:ore_end_modded_2', 5);
blacklist('netherendingores:ore_end_modded_2', 6);
blacklist('netherendingores:ore_end_modded_2', 7);
blacklist('netherendingores:ore_end_modded_2', 8);
blacklist('netherendingores:ore_end_modded_2', 9);
infinFurnace(utils.get('netherendingores:ore_end_vanilla', 1), utils.get('minecraft:diamond_ore', 0, 2));
infinFurnace(utils.get('netherendingores:ore_end_vanilla', 2), utils.get('minecraft:emerald_ore', 0, 2));
infinFurnace(utils.get('netherendingores:ore_end_vanilla', 3), utils.get('minecraft:gold_ore', 0, 2));
infinFurnace(utils.get('netherendingores:ore_end_vanilla', 4), utils.get('minecraft:iron_ore', 0, 2));
infinFurnace(utils.get('netherendingores:ore_end_vanilla', 5), utils.get('minecraft:lapis_ore', 0, 2));
infinFurnace(utils.get('netherendingores:ore_end_vanilla', 6), utils.get('minecraft:redstone_ore', 0, 2));
infinFurnace(utils.get('netherendingores:ore_end_vanilla'), utils.get('minecraft:coal_ore', 0, 2));
infinFurnace(utils.get('netherendingores:ore_nether_modded_1', 1), utils.get('thermalfoundation:ore', 0, 2));
blacklist('netherendingores:ore_nether_modded_1', 2);
infinFurnace(utils.get('netherendingores:ore_nether_modded_1', 3), utils.get('thermalfoundation:ore', 3, 2));
blacklist('netherendingores:ore_nether_modded_1', 4);
infinFurnace(utils.get('netherendingores:ore_nether_modded_1', 5), utils.get('thermalfoundation:ore', 5, 2));
infinFurnace(utils.get('netherendingores:ore_nether_modded_1', 6), utils.get('thermalfoundation:ore', 6, 2));
infinFurnace(utils.get('netherendingores:ore_nether_modded_1', 7), utils.get('thermalfoundation:ore', 2, 2));
infinFurnace(utils.get('netherendingores:ore_nether_modded_1', 8), utils.get('thermalfoundation:ore', 1, 2));
infinFurnace(utils.get('netherendingores:ore_nether_modded_1', 9), utils.get('appliedenergistics2:quartz_ore', 0, 2));
infinFurnace(utils.get('netherendingores:ore_nether_modded_1', 10), utils.get('appliedenergistics2:charged_quartz_ore', 0, 2));
infinFurnace(utils.get('netherendingores:ore_nether_modded_1', 11), utils.get('mekanism:oreblock', 0, 2));
infinFurnace(utils.get('netherendingores:ore_nether_modded_1', 12), utils.get('immersiveengineering:ore', 5, 2));
blacklist('netherendingores:ore_nether_modded_1', 14);
infinFurnace(utils.get('netherendingores:ore_nether_modded_1'), utils.get('thermalfoundation:ore', 4, 2));
infinFurnace(utils.get('netherendingores:ore_nether_modded_2', 1), utils.get('biomesoplenty:gem_ore', 1, 2));
blacklist('netherendingores:ore_nether_modded_2', 2);
infinFurnace(utils.get('netherendingores:ore_nether_modded_2', 3), utils.get('biomesoplenty:gem_ore', 2, 2));
blacklist('netherendingores:ore_nether_modded_2', 5);
blacklist('netherendingores:ore_nether_modded_2', 6);
blacklist('netherendingores:ore_nether_modded_2', 7);
blacklist('netherendingores:ore_nether_modded_2', 8);
blacklist('netherendingores:ore_nether_modded_2', 9);
infinFurnace(utils.get('netherendingores:ore_nether_vanilla', 1), utils.get('minecraft:diamond_ore', 0, 2));
infinFurnace(utils.get('netherendingores:ore_nether_vanilla', 2), utils.get('minecraft:emerald_ore', 0, 2));
infinFurnace(utils.get('netherendingores:ore_nether_vanilla', 3), utils.get('minecraft:gold_ore', 0, 2));
infinFurnace(utils.get('netherendingores:ore_nether_vanilla', 4), utils.get('minecraft:iron_ore', 0, 2));
infinFurnace(utils.get('netherendingores:ore_nether_vanilla', 5), utils.get('minecraft:lapis_ore', 0, 2));
infinFurnace(utils.get('netherendingores:ore_nether_vanilla', 6), utils.get('minecraft:redstone_ore', 0, 2));
infinFurnace(utils.get('netherendingores:ore_nether_vanilla'), utils.get('minecraft:coal_ore', 0, 2));
infinFurnace(utils.get('netherendingores:ore_other_1', 1), utils.get('minecraft:quartz_ore', 0, 2));
infinFurnace(utils.get('netherendingores:ore_other_1', 3), utils.get('tconstruct:ore', 1, 2));
infinFurnace(utils.get('netherendingores:ore_other_1', 4), utils.get('tconstruct:ingots'));
infinFurnace(utils.get('netherendingores:ore_other_1', 5), utils.get('tconstruct:ore', 0, 2));
blacklist('netherendingores:ore_other_1');
blacklist('nuclearcraft:americium', 2);
blacklist('nuclearcraft:americium', 3);
blacklist('nuclearcraft:americium', 4);
blacklist('nuclearcraft:americium', 7);
blacklist('nuclearcraft:americium', 8);
blacklist('nuclearcraft:americium', 9);
blacklist('nuclearcraft:americium', 12);
blacklist('nuclearcraft:americium', 13);
blacklist('nuclearcraft:americium', 14);
blacklist('nuclearcraft:berkelium', 2);
blacklist('nuclearcraft:berkelium', 3);
blacklist('nuclearcraft:berkelium', 4);
blacklist('nuclearcraft:berkelium', 7);
blacklist('nuclearcraft:berkelium', 8);
blacklist('nuclearcraft:berkelium', 9);
blacklist('nuclearcraft:californium', 2);
blacklist('nuclearcraft:californium', 3);
blacklist('nuclearcraft:californium', 4);
blacklist('nuclearcraft:californium', 7);
blacklist('nuclearcraft:californium', 8);
blacklist('nuclearcraft:californium', 9);
blacklist('nuclearcraft:californium', 12);
blacklist('nuclearcraft:californium', 13);
blacklist('nuclearcraft:californium', 14);
blacklist('nuclearcraft:californium', 17);
blacklist('nuclearcraft:californium', 18);
blacklist('nuclearcraft:californium', 19);
infinFurnace(utils.get('nuclearcraft:compound', 12), utils.get('nuclearcraft:compound', 13));
blacklist('nuclearcraft:curium', 2);
blacklist('nuclearcraft:curium', 3);
blacklist('nuclearcraft:curium', 4);
blacklist('nuclearcraft:curium', 7);
blacklist('nuclearcraft:curium', 8);
blacklist('nuclearcraft:curium', 9);
blacklist('nuclearcraft:curium', 12);
blacklist('nuclearcraft:curium', 13);
blacklist('nuclearcraft:curium', 14);
blacklist('nuclearcraft:curium', 17);
blacklist('nuclearcraft:curium', 18);
blacklist('nuclearcraft:curium', 19);
blacklist('nuclearcraft:dust', 3);
blacklist('nuclearcraft:dust', 5);
blacklist('nuclearcraft:dust', 6);
blacklist('nuclearcraft:dust', 7);
blacklist('nuclearcraft:dust', 8);
blacklist('nuclearcraft:dust', 9);
blacklist('nuclearcraft:dust', 10);
blacklist('nuclearcraft:dust', 11);
blacklist('nuclearcraft:dust', 12);
blacklist('nuclearcraft:dust', 13);
blacklist('nuclearcraft:dust', 14);
blacklist('nuclearcraft:dust2', 1);
blacklist('nuclearcraft:dust2');
infinFurnace(utils.get('nuclearcraft:flour'), utils.get('minecraft:bread'));
infinFurnace(utils.get('nuclearcraft:gem_dust', 1), utils.get('nuclearcraft:dust', 14));
blacklist('nuclearcraft:ingot', 14);
blacklist('nuclearcraft:ingot', 15);
blacklist('nuclearcraft:ingot2', 2);
blacklist('nuclearcraft:ingot2', 3);
blacklist('nuclearcraft:ingot2', 4);
blacklist('nuclearcraft:ingot2', 6);
infinFurnace(utils.get('nuclearcraft:ingot2'), utils.get('nuclearcraft:ingot', 10));
blacklist('nuclearcraft:neptunium', 2);
blacklist('nuclearcraft:neptunium', 3);
blacklist('nuclearcraft:neptunium', 4);
blacklist('nuclearcraft:neptunium', 7);
blacklist('nuclearcraft:neptunium', 8);
blacklist('nuclearcraft:neptunium', 9);
infinFurnace(utils.get('nuclearcraft:ore', 3), utils.get('nuclearcraft:ingot', 3));
infinFurnace(utils.get('nuclearcraft:ore', 5), utils.get('nuclearcraft:ingot', 5));
infinFurnace(utils.get('nuclearcraft:ore', 6), utils.get('nuclearcraft:ingot', 6));
infinFurnace(utils.get('nuclearcraft:ore', 7), utils.get('nuclearcraft:ingot', 7));
infinFurnace(utils.get('nuclearcraft:part', 21), utils.get('nuclearcraft:part', 22));
blacklist('nuclearcraft:plutonium', 2);
blacklist('nuclearcraft:plutonium', 3);
blacklist('nuclearcraft:plutonium', 4);
blacklist('nuclearcraft:plutonium', 7);
blacklist('nuclearcraft:plutonium', 8);
blacklist('nuclearcraft:plutonium', 9);
blacklist('nuclearcraft:plutonium', 12);
blacklist('nuclearcraft:plutonium', 13);
blacklist('nuclearcraft:plutonium', 14);
blacklist('nuclearcraft:plutonium', 17);
blacklist('nuclearcraft:plutonium', 18);
blacklist('nuclearcraft:plutonium', 19);
blacklist('nuclearcraft:uranium', 2);
blacklist('nuclearcraft:uranium', 3);
blacklist('nuclearcraft:uranium', 4);
blacklist('nuclearcraft:uranium', 7);
blacklist('nuclearcraft:uranium', 8);
blacklist('nuclearcraft:uranium', 9);
blacklist('nuclearcraft:uranium', 12);
blacklist('nuclearcraft:uranium', 13);
blacklist('nuclearcraft:uranium', 14);
infinFurnace(utils.get('opencomputers:material', 2), utils.get('opencomputers:material', 4));
blacklist('qmd:copernicium', 2);
blacklist('qmd:copernicium', 3);
blacklist('qmd:copernicium', 4);
blacklist('qmd:dust', 1);
blacklist('qmd:dust', 2);
blacklist('qmd:dust', 5);
blacklist('qmd:dust', 6);
blacklist('qmd:dust', 7);
blacklist('qmd:dust', 8);
blacklist('qmd:dust', 9);
blacklist('qmd:dust', 10);
blacklist('qmd:dust', 11);
blacklist('qmd:dust', 12);
blacklist('qmd:dust', 13);
blacklist('qmd:dust', 14);
blacklist('qmd:dust');
blacklist('qmd:dust2', 1);
blacklist('qmd:dust2');
infinFurnace(utils.get('quark:biome_cobblestone', 2), utils.get('minecraft:stone'));
blacklist('quark:crab_leg', W);
infinFurnace(utils.get('quark:frog_leg', W), utils.get('quark:cooked_frog_leg'));
infinFurnace(utils.get('quark:trowel'), utils.get('minecraft:iron_nugget'));
infinFurnace(utils.get('randomthings:biomestone'), utils.get('randomthings:biomestone', 1));
blacklist('rats:marbled_cheese_brick', W);
infinFurnace(utils.get('rats:marbled_cheese_raw', W), utils.get('rats:marbled_cheese'));
infinFurnace(utils.get('rats:rat_nugget_ore', 1, 1, {OreItem: {Count: 1, id: "thaumcraft:ore_amber", Damage: 0 as short}, IngotItem: {Count: 1, id: "thaumcraft:amber", Damage: 0 as short}}), utils.get('thaumcraft:amber'));
infinFurnace(utils.get('rats:rat_nugget_ore', 2, 1, {OreItem: {Count: 1, id: "forestry:resources", Damage: 0 as short}, IngotItem: {Count: 1, id: "forestry:apatite", Damage: 0 as short}}), utils.get('forestry:apatite'));
infinFurnace(utils.get('rats:rat_nugget_ore', 3, 1, {OreItem: {Count: 1, id: "astralsorcery:blockcustomsandore", Damage: 0 as short}, IngotItem: {Count: 3, id: "astralsorcery:itemcraftingcomponent", Damage: 0 as short}}), utils.get('astralsorcery:itemcraftingcomponent', 0, 3));
infinFurnace(utils.get('rats:rat_nugget_ore', 4, 1, {OreItem: {Count: 1, id: "tconstruct:ore", Damage: 1 as short}, IngotItem: {Count: 1, id: "tconstruct:ingots", Damage: 1 as short}}), utils.get('tconstruct:ingots', 1));
infinFurnace(utils.get('rats:rat_nugget_ore', 5, 1, {OreItem: {Count: 1, id: "twilightforest:armor_shard_cluster", Damage: 0 as short}, IngotItem: {Count: 1, id: "twilightforest:knightmetal_ingot", Damage: 0 as short}}), utils.get('twilightforest:knightmetal_ingot'));
infinFurnace(utils.get('rats:rat_nugget_ore', 6, 1, {OreItem: {Count: 1, id: "actuallyadditions:block_misc", Damage: 3 as short}, IngotItem: {Count: 1, id: "actuallyadditions:item_misc", Damage: 5 as short}}), utils.get('actuallyadditions:item_misc', 5));
infinFurnace(utils.get('rats:rat_nugget_ore', 7, 1, {OreItem: {Count: 1, id: "nuclearcraft:ore", Damage: 5 as short}, IngotItem: {Count: 1, id: "nuclearcraft:ingot", Damage: 5 as short}}), utils.get('nuclearcraft:ingot', 5));
infinFurnace(utils.get('rats:rat_nugget_ore', 8, 1, {OreItem: {Count: 1, id: "thaumcraft:ore_cinnabar", Damage: 0 as short}, IngotItem: {Count: 1, id: "thaumcraft:quicksilver", Damage: 0 as short}}), utils.get('thaumcraft:quicksilver'));
infinFurnace(utils.get('rats:rat_nugget_ore', 9, 1, {OreItem: {Count: 1, id: "minecraft:coal_ore", Damage: 0 as short}, IngotItem: {Count: 1, id: "minecraft:coal", Damage: 0 as short}}), utils.get('minecraft:coal'));
infinFurnace(utils.get('rats:rat_nugget_ore', 10, 1, {OreItem: {Count: 1, id: "tconstruct:ore", Damage: 0 as short}, IngotItem: {Count: 1, id: "tconstruct:ingots", Damage: 0 as short}}), utils.get('tconstruct:ingots'));
infinFurnace(utils.get('rats:rat_nugget_ore', 11, 1, {OreItem: {Count: 1, id: "thermalfoundation:ore", Damage: 0 as short}, IngotItem: {Count: 1, id: "thermalfoundation:material", Damage: 128 as short}}), utils.get('thermalfoundation:material', 128));
infinFurnace(utils.get('rats:rat_nugget_ore', 12, 1, {OreItem: {Count: 1, id: "minecraft:diamond_ore", Damage: 0 as short}, IngotItem: {Count: 1, id: "minecraft:diamond", Damage: 0 as short}}), utils.get('minecraft:diamond'));
infinFurnace(utils.get('rats:rat_nugget_ore', 13, 1, {OreItem: {Count: 1, id: "libvulpes:ore0", Damage: 0 as short}, IngotItem: {Count: 1, id: "libvulpes:productdust", Damage: 0 as short}}), utils.get('libvulpes:productdust'));
infinFurnace(utils.get('rats:rat_nugget_ore', 14, 1, {OreItem: {Count: 1, id: "minecraft:emerald_ore", Damage: 0 as short}, IngotItem: {Count: 1, id: "minecraft:emerald", Damage: 0 as short}}), utils.get('minecraft:emerald'));
infinFurnace(utils.get('rats:rat_nugget_ore', 15, 1, {OreItem: {Count: 1, id: "netherendingores:ore_end_modded_1", Damage: 0 as short}, IngotItem: {Count: 2, id: "thermalfoundation:ore", Damage: 4 as short}}), utils.get('thermalfoundation:ore', 4, 2));
blacklist('rats:rat_nugget_ore', 16, 1, {OreItem: {Count: 1, id: "netherendingores:ore_end_modded_2", Damage: 5 as short}, IngotItem: {Count: 2, id: "netherendingores:ore_other_1", Damage: 6 as short}});
infinFurnace(utils.get('rats:rat_nugget_ore', 17, 1, {OreItem: {Count: 1, id: "netherendingores:ore_other_1", Damage: 3 as short}, IngotItem: {Count: 2, id: "tconstruct:ore", Damage: 1 as short}}), utils.get('tconstruct:ore', 1, 2));
blacklist('rats:rat_nugget_ore', 18, 1, {OreItem: {Count: 1, id: "netherendingores:ore_end_modded_2", Damage: 8 as short}, IngotItem: {Count: 2, id: "netherendingores:ore_other_1", Damage: 9 as short}});
infinFurnace(utils.get('rats:rat_nugget_ore', 19, 1, {OreItem: {Count: 1, id: "netherendingores:ore_end_modded_1", Damage: 9 as short}, IngotItem: {Count: 2, id: "appliedenergistics2:quartz_ore", Damage: 0 as short}}), utils.get('appliedenergistics2:quartz_ore', 0, 2));
infinFurnace(utils.get('rats:rat_nugget_ore', 20, 1, {OreItem: {Count: 1, id: "netherendingores:ore_end_modded_1", Damage: 10 as short}, IngotItem: {Count: 2, id: "appliedenergistics2:charged_quartz_ore", Damage: 0 as short}}), utils.get('appliedenergistics2:charged_quartz_ore', 0, 2));
infinFurnace(utils.get('rats:rat_nugget_ore', 21, 1, {OreItem: {Count: 1, id: "netherendingores:ore_end_vanilla", Damage: 0 as short}, IngotItem: {Count: 2, id: "minecraft:coal_ore", Damage: 0 as short}}), utils.get('minecraft:coal_ore', 0, 2));
infinFurnace(utils.get('rats:rat_nugget_ore', 22, 1, {OreItem: {Count: 1, id: "netherendingores:ore_other_1", Damage: 5 as short}, IngotItem: {Count: 2, id: "tconstruct:ore", Damage: 0 as short}}), utils.get('tconstruct:ore', 0, 2));
infinFurnace(utils.get('rats:rat_nugget_ore', 23, 1, {OreItem: {Count: 1, id: "netherendingores:ore_end_modded_1", Damage: 1 as short}, IngotItem: {Count: 2, id: "thermalfoundation:ore", Damage: 0 as short}}), utils.get('thermalfoundation:ore', 0, 2));
infinFurnace(utils.get('rats:rat_nugget_ore', 24, 1, {OreItem: {Count: 1, id: "netherendingores:ore_end_vanilla", Damage: 1 as short}, IngotItem: {Count: 2, id: "minecraft:diamond_ore", Damage: 0 as short}}), utils.get('minecraft:diamond_ore', 0, 2));
infinFurnace(utils.get('rats:rat_nugget_ore', 25, 1, {OreItem: {Count: 1, id: "netherendingores:ore_end_modded_1", Damage: 14 as short}, IngotItem: {Count: 2, id: "libvulpes:ore0", Damage: 0 as short}}), utils.get('libvulpes:ore0', 0, 2));
infinFurnace(utils.get('rats:rat_nugget_ore', 26, 1, {OreItem: {Count: 1, id: "netherendingores:ore_end_vanilla", Damage: 2 as short}, IngotItem: {Count: 2, id: "minecraft:emerald_ore", Damage: 0 as short}}), utils.get('minecraft:emerald_ore', 0, 2));
infinFurnace(utils.get('rats:rat_nugget_ore', 27, 1, {OreItem: {Count: 1, id: "netherendingores:ore_end_vanilla", Damage: 3 as short}, IngotItem: {Count: 2, id: "minecraft:gold_ore", Damage: 0 as short}}), utils.get('minecraft:gold_ore', 0, 2));
blacklist('rats:rat_nugget_ore', 28, 1, {OreItem: {Count: 1, id: "netherendingores:ore_end_modded_2", Damage: 6 as short}, IngotItem: {Count: 2, id: "netherendingores:ore_other_1", Damage: 7 as short}});
blacklist('rats:rat_nugget_ore', 29, 1, {OreItem: {Count: 1, id: "netherendingores:ore_end_modded_2", Damage: 9 as short}, IngotItem: {Count: 2, id: "netherendingores:ore_other_1", Damage: 10 as short}});
infinFurnace(utils.get('rats:rat_nugget_ore', 30, 1, {OreItem: {Count: 1, id: "netherendingores:ore_end_modded_1", Damage: 2 as short}, IngotItem: {Count: 2, id: "thermalfoundation:ore", Damage: 7 as short}}), utils.get('thermalfoundation:ore', 7, 2));
infinFurnace(utils.get('rats:rat_nugget_ore', 31, 1, {OreItem: {Count: 1, id: "netherendingores:ore_end_vanilla", Damage: 4 as short}, IngotItem: {Count: 2, id: "minecraft:iron_ore", Damage: 0 as short}}), utils.get('minecraft:iron_ore', 0, 2));
infinFurnace(utils.get('rats:rat_nugget_ore', 32, 1, {OreItem: {Count: 1, id: "netherendingores:ore_end_vanilla", Damage: 5 as short}, IngotItem: {Count: 2, id: "minecraft:lapis_ore", Damage: 0 as short}}), utils.get('minecraft:lapis_ore', 0, 2));
infinFurnace(utils.get('rats:rat_nugget_ore', 33, 1, {OreItem: {Count: 1, id: "netherendingores:ore_end_modded_1", Damage: 3 as short}, IngotItem: {Count: 2, id: "thermalfoundation:ore", Damage: 3 as short}}), utils.get('thermalfoundation:ore', 3, 2));
infinFurnace(utils.get('rats:rat_nugget_ore', 34, 1, {OreItem: {Count: 1, id: "netherendingores:ore_end_modded_1", Damage: 4 as short}, IngotItem: {Count: 2, id: "thermalfoundation:ore", Damage: 8 as short}}), utils.get('thermalfoundation:ore', 8, 2));
infinFurnace(utils.get('rats:rat_nugget_ore', 35, 1, {OreItem: {Count: 1, id: "netherendingores:ore_end_modded_1", Damage: 5 as short}, IngotItem: {Count: 2, id: "thermalfoundation:ore", Damage: 5 as short}}), utils.get('thermalfoundation:ore', 5, 2));
infinFurnace(utils.get('rats:rat_nugget_ore', 36, 1, {OreItem: {Count: 1, id: "netherendingores:ore_end_modded_1", Damage: 11 as short}, IngotItem: {Count: 2, id: "mekanism:oreblock", Damage: 0 as short}}), utils.get('mekanism:oreblock', 0, 2));
infinFurnace(utils.get('rats:rat_nugget_ore', 37, 1, {OreItem: {Count: 1, id: "netherendingores:ore_end_modded_2", Damage: 3 as short}, IngotItem: {Count: 2, id: "biomesoplenty:gem_ore", Damage: 2 as short}}), utils.get('biomesoplenty:gem_ore', 2, 2));
infinFurnace(utils.get('rats:rat_nugget_ore', 38, 1, {OreItem: {Count: 1, id: "netherendingores:ore_end_modded_1", Damage: 6 as short}, IngotItem: {Count: 2, id: "thermalfoundation:ore", Damage: 6 as short}}), utils.get('thermalfoundation:ore', 6, 2));
infinFurnace(utils.get('rats:rat_nugget_ore', 39, 1, {OreItem: {Count: 1, id: "netherendingores:ore_other_1", Damage: 1 as short}, IngotItem: {Count: 2, id: "minecraft:quartz_ore", Damage: 0 as short}}), utils.get('minecraft:quartz_ore', 0, 2));
infinFurnace(utils.get('rats:rat_nugget_ore', 40, 1, {OreItem: {Count: 1, id: "netherendingores:ore_end_vanilla", Damage: 6 as short}, IngotItem: {Count: 2, id: "minecraft:redstone_ore", Damage: 0 as short}}), utils.get('minecraft:redstone_ore', 0, 2));
infinFurnace(utils.get('rats:rat_nugget_ore', 41, 1, {OreItem: {Count: 1, id: "netherendingores:ore_end_modded_2", Damage: 1 as short}, IngotItem: {Count: 2, id: "biomesoplenty:gem_ore", Damage: 1 as short}}), utils.get('biomesoplenty:gem_ore', 1, 2));
infinFurnace(utils.get('rats:rat_nugget_ore', 42, 1, {OreItem: {Count: 1, id: "netherendingores:ore_end_modded_2", Damage: 2 as short}, IngotItem: {Count: 2, id: "biomesoplenty:gem_ore", Damage: 6 as short}}), utils.get('biomesoplenty:gem_ore', 6, 2));
infinFurnace(utils.get('rats:rat_nugget_ore', 43, 1, {OreItem: {Count: 1, id: "netherendingores:ore_end_modded_1", Damage: 7 as short}, IngotItem: {Count: 2, id: "thermalfoundation:ore", Damage: 2 as short}}), utils.get('thermalfoundation:ore', 2, 2));
infinFurnace(utils.get('rats:rat_nugget_ore', 44, 1, {OreItem: {Count: 1, id: "netherendingores:ore_end_modded_1", Damage: 8 as short}, IngotItem: {Count: 2, id: "thermalfoundation:ore", Damage: 1 as short}}), utils.get('thermalfoundation:ore', 1, 2));
infinFurnace(utils.get('rats:rat_nugget_ore', 45, 1, {OreItem: {Count: 1, id: "netherendingores:ore_end_modded_1", Damage: 12 as short}, IngotItem: {Count: 2, id: "immersiveengineering:ore", Damage: 5 as short}}), utils.get('immersiveengineering:ore', 5, 2));
blacklist('rats:rat_nugget_ore', 46, 1, {OreItem: {Count: 1, id: "netherendingores:ore_end_modded_2", Damage: 7 as short}, IngotItem: {Count: 2, id: "netherendingores:ore_other_1", Damage: 8 as short}});
infinFurnace(utils.get('rats:rat_nugget_ore', 47, 1, {OreItem: {Count: 1, id: "biomesoplenty:gem_ore", Damage: 0 as short}, IngotItem: {Count: 1, id: "biomesoplenty:gem", Damage: 0 as short}}), utils.get('biomesoplenty:gem'));
infinFurnace(utils.get('rats:rat_nugget_ore', 48, 1, {OreItem: {Count: 1, id: "minecraft:gold_ore", Damage: 0 as short}, IngotItem: {Count: 1, id: "minecraft:gold_ingot", Damage: 0 as short}}), utils.get('minecraft:gold_ingot'));
infinFurnace(utils.get('rats:rat_nugget_ore', 49, 1, {OreItem: {Count: 1, id: "thermalfoundation:ore", Damage: 7 as short}, IngotItem: {Count: 1, id: "thermalfoundation:material", Damage: 135 as short}}), utils.get('thermalfoundation:material', 135));
infinFurnace(utils.get('rats:rat_nugget_ore', 50, 1, {OreItem: {Count: 1, id: "minecraft:iron_ore", Damage: 0 as short}, IngotItem: {Count: 1, id: "minecraft:iron_ingot", Damage: 0 as short}}), utils.get('minecraft:iron_ingot'));
infinFurnace(utils.get('rats:rat_nugget_ore', 51, 1, {OreItem: {Count: 1, id: "minecraft:lapis_ore", Damage: 0 as short}, IngotItem: {Count: 1, id: "minecraft:dye", Damage: 4 as short}}), utils.get('minecraft:dye', 4));
infinFurnace(utils.get('rats:rat_nugget_ore', 52, 1, {OreItem: {Count: 1, id: "thermalfoundation:ore", Damage: 3 as short}, IngotItem: {Count: 1, id: "thermalfoundation:material", Damage: 131 as short}}), utils.get('thermalfoundation:material', 131));
infinFurnace(utils.get('rats:rat_nugget_ore', 53, 1, {OreItem: {Count: 1, id: "nuclearcraft:ore", Damage: 6 as short}, IngotItem: {Count: 1, id: "nuclearcraft:ingot", Damage: 6 as short}}), utils.get('nuclearcraft:ingot', 6));
infinFurnace(utils.get('rats:rat_nugget_ore', 54, 1, {OreItem: {Count: 1, id: "nuclearcraft:ore", Damage: 7 as short}, IngotItem: {Count: 1, id: "nuclearcraft:ingot", Damage: 7 as short}}), utils.get('nuclearcraft:ingot', 7));
infinFurnace(utils.get('rats:rat_nugget_ore', 55, 1, {OreItem: {Count: 1, id: "biomesoplenty:gem_ore", Damage: 5 as short}, IngotItem: {Count: 1, id: "biomesoplenty:gem", Damage: 5 as short}}), utils.get('biomesoplenty:gem', 5));
infinFurnace(utils.get('rats:rat_nugget_ore', 56, 1, {OreItem: {Count: 1, id: "thermalfoundation:ore", Damage: 8 as short}, IngotItem: {Count: 1, id: "thermalfoundation:material", Damage: 136 as short}}), utils.get('thermalfoundation:material', 136));
infinFurnace(utils.get('rats:rat_nugget_ore', 79, 1, {OreItem: {Count: 1, id: "minecraft:quartz_ore", Damage: 0 as short}, IngotItem: {Count: 1, id: "minecraft:quartz", Damage: 0 as short}}), utils.get('minecraft:quartz'));
infinFurnace(utils.get('rats:rat_nugget_ore', 87, 1, {OreItem: {Count: 1, id: "thermalfoundation:ore", Damage: 5 as short}, IngotItem: {Count: 1, id: "thermalfoundation:material", Damage: 133 as short}}), utils.get('thermalfoundation:material', 133));
infinFurnace(utils.get('rats:rat_nugget_ore', 88, 1, {OreItem: {Count: 1, id: "mekanism:oreblock", Damage: 0 as short}, IngotItem: {Count: 1, id: "mekanism:ingot", Damage: 1 as short}}), utils.get('mekanism:ingot', 1));
infinFurnace(utils.get('rats:rat_nugget_ore', 89, 1, {OreItem: {Count: 1, id: "biomesoplenty:gem_ore", Damage: 2 as short}, IngotItem: {Count: 1, id: "biomesoplenty:gem", Damage: 2 as short}}), utils.get('biomesoplenty:gem', 2));
infinFurnace(utils.get('rats:rat_nugget_ore', 90, 1, {OreItem: {Count: 1, id: "contenttweaker:ore_phosphor", Damage: 0 as short}, IngotItem: {Count: 1, id: "contenttweaker:nugget_phosphor", Damage: 0 as short}}), utils.get('contenttweaker:nugget_phosphor'));
infinFurnace(utils.get('rats:rat_nugget_ore', 91, 1, {OreItem: {Count: 1, id: "thermalfoundation:ore", Damage: 6 as short}, IngotItem: {Count: 1, id: "thermalfoundation:material", Damage: 134 as short}}), utils.get('thermalfoundation:material', 134));
infinFurnace(utils.get('rats:rat_nugget_ore', 92, 1, {OreItem: {Count: 1, id: "twilightforest:ironwood_raw", Damage: 0 as short}, IngotItem: {Count: 2, id: "twilightforest:ironwood_ingot", Damage: 0 as short}}), utils.get('twilightforest:ironwood_ingot', 0, 2));
infinFurnace(utils.get('rats:rat_nugget_ore', 93, 1, {OreItem: {Count: 1, id: "minecraft:redstone_ore", Damage: 0 as short}, IngotItem: {Count: 1, id: "minecraft:redstone", Damage: 0 as short}}), utils.get('minecraft:redstone'));
infinFurnace(utils.get('rats:rat_nugget_ore', 94, 1, {OreItem: {Count: 1, id: "biomesoplenty:gem_ore", Damage: 1 as short}, IngotItem: {Count: 1, id: "biomesoplenty:gem", Damage: 1 as short}}), utils.get('biomesoplenty:gem', 1));
infinFurnace(utils.get('rats:rat_nugget_ore', 95, 1, {OreItem: {Count: 1, id: "biomesoplenty:gem_ore", Damage: 6 as short}, IngotItem: {Count: 1, id: "biomesoplenty:gem", Damage: 6 as short}}), utils.get('biomesoplenty:gem', 6));
infinFurnace(utils.get('rats:rat_nugget_ore', 96, 1, {OreItem: {Count: 1, id: "thermalfoundation:ore", Damage: 2 as short}, IngotItem: {Count: 1, id: "thermalfoundation:material", Damage: 130 as short}}), utils.get('thermalfoundation:material', 130));
infinFurnace(utils.get('rats:rat_nugget_ore', 97, 1, {OreItem: {Count: 1, id: "astralsorcery:blockcustomore", Damage: 1 as short}, IngotItem: {Count: 1, id: "astralsorcery:itemcraftingcomponent", Damage: 1 as short}}), utils.get('astralsorcery:itemcraftingcomponent', 1));
infinFurnace(utils.get('rats:rat_nugget_ore', 98, 1, {OreItem: {Count: 1, id: "biomesoplenty:gem_ore", Damage: 4 as short}, IngotItem: {Count: 1, id: "biomesoplenty:gem", Damage: 4 as short}}), utils.get('biomesoplenty:gem', 4));
infinFurnace(utils.get('rats:rat_nugget_ore', 99, 1, {OreItem: {Count: 1, id: "nuclearcraft:ore", Damage: 3 as short}, IngotItem: {Count: 1, id: "nuclearcraft:ingot", Damage: 3 as short}}), utils.get('nuclearcraft:ingot', 3));
infinFurnace(utils.get('rats:rat_nugget_ore', 100, 1, {OreItem: {Count: 1, id: "thermalfoundation:ore", Damage: 1 as short}, IngotItem: {Count: 1, id: "thermalfoundation:material", Damage: 129 as short}}), utils.get('thermalfoundation:material', 129));
infinFurnace(utils.get('rats:rat_nugget_ore', 101, 1, {OreItem: {Count: 1, id: "biomesoplenty:gem_ore", Damage: 3 as short}, IngotItem: {Count: 1, id: "biomesoplenty:gem", Damage: 3 as short}}), utils.get('biomesoplenty:gem', 3));
infinFurnace(utils.get('rats:rat_nugget_ore', 102, 1, {OreItem: {Count: 1, id: "endreborn:block_wolframium_ore", Damage: 0 as short}, IngotItem: {Count: 1, id: "endreborn:item_ingot_wolframium", Damage: 0 as short}}), utils.get('endreborn:item_ingot_wolframium'));
infinFurnace(utils.get('rats:rat_nugget_ore', 103, 1, {OreItem: {Count: 1, id: "immersiveengineering:ore", Damage: 5 as short}, IngotItem: {Count: 1, id: "immersiveengineering:metal", Damage: 5 as short}}), utils.get('immersiveengineering:metal', 5));
infinFurnace(utils.get('rats:rat_nugget_ore', 0, 1, {OreItem: {Count: 1, id: "thermalfoundation:ore", Damage: 4 as short}, IngotItem: {Count: 1, id: "thermalfoundation:material", Damage: 132 as short}}), utils.get('thermalfoundation:material', 132));
infinFurnace(utils.get('rats:raw_rat', W), utils.get('rats:cooked_rat'));
blacklist('rustic:dust_tiny_iron');
infinFurnace(utils.get('rustic:honeycomb'), utils.get('rustic:beeswax'));
// SKIP: 'rustic:log', 1
// SKIP: 'rustic:log'
infinFurnace(utils.get('tcomplement:scorched_block', 1), utils.get('tcomplement:scorched_block'));
blacklist('tcomplement:scorched_block', 3);
blacklist('tcomplement:scorched_slab', 3);
blacklist('tcomplement:scorched_stairs_brick', W);
infinFurnace(utils.get('tconevo:earth_material_block'), utils.get('tconevo:material', 1));
infinFurnace(utils.get('tconevo:edible'), utils.get('tconevo:edible', 1));
blacklist('tconevo:metal', 1);
blacklist('tconevo:metal', 6);
blacklist('tconevo:metal', 11);
blacklist('tconevo:metal', 16);
blacklist('tconevo:metal', 21);
blacklist('tconevo:metal', 26);
blacklist('tconevo:metal', 31);
blacklist('tconevo:metal', 36);
blacklist('tconevo:metal', 41);
infinFurnace(utils.get('tconstruct:brownstone', 1), utils.get('tconstruct:brownstone'));
blacklist('tconstruct:brownstone', 3);
infinFurnace(utils.get('tconstruct:ore', 1), utils.get('tconstruct:ingots', 1));
infinFurnace(utils.get('tconstruct:ore'), utils.get('tconstruct:ingots'));
blacklist('tconstruct:seared', 3);
infinFurnace(utils.get('tconstruct:slime_congealed', 1), utils.get('tconstruct:slime_channel', 1, 3));
infinFurnace(utils.get('tconstruct:slime_congealed', 2), utils.get('tconstruct:slime_channel', 2, 3));
infinFurnace(utils.get('tconstruct:slime_congealed', 3), utils.get('tconstruct:slime_channel', 3, 3));
infinFurnace(utils.get('tconstruct:slime_congealed', 4), utils.get('tconstruct:slime_channel', 4, 3));
blacklist('tconstruct:slime_congealed', 5);
infinFurnace(utils.get('tconstruct:slime_congealed'), utils.get('tconstruct:slime_channel', 0, 3));
infinFurnace(utils.get('tconstruct:soil', 1), utils.get('tconstruct:materials', 9));
infinFurnace(utils.get('tconstruct:soil', 2), utils.get('tconstruct:materials', 10));
infinFurnace(utils.get('tconstruct:soil', 3), utils.get('tconstruct:soil', 4));
infinFurnace(utils.get('tconstruct:soil', 5), utils.get('tconstruct:materials', 11));
infinFurnace(utils.get('tconstruct:soil'), utils.get('tconstruct:materials'));
infinFurnace(utils.get('tconstruct:spaghetti', 2), utils.get('tconstruct:moms_spaghetti'));
infinFurnace(utils.get('thaumcraft:cluster', 1), utils.get('minecraft:gold_ingot', 0, 2));
infinFurnace(utils.get('thaumcraft:cluster', 2), utils.get('thermalfoundation:material', 128, 2));
infinFurnace(utils.get('thaumcraft:cluster', 3), utils.get('thermalfoundation:material', 129, 2));
infinFurnace(utils.get('thaumcraft:cluster', 4), utils.get('thermalfoundation:material', 130, 2));
infinFurnace(utils.get('thaumcraft:cluster', 5), utils.get('thermalfoundation:material', 131, 2));
infinFurnace(utils.get('thaumcraft:cluster', 6), utils.get('thaumcraft:quicksilver', 0, 2));
infinFurnace(utils.get('thaumcraft:cluster', 7), utils.get('minecraft:quartz', 0, 5));
infinFurnace(utils.get('thaumcraft:cluster'), utils.get('minecraft:iron_ingot', 0, 2));
// SKIP: 'thaumcraft:log_greatwood', W
// SKIP: 'thaumcraft:log_silverwood', W
infinFurnace(utils.get('thaumcraft:ore_amber', W), utils.get('thaumcraft:amber'));
infinFurnace(utils.get('thaumcraft:ore_cinnabar', W), utils.get('thaumcraft:quicksilver'));
blacklist('thaumcraft:ore_quartz', W);
infinFurnace(utils.get('thaumicaugmentation:stone', 10), utils.get('thaumcraft:stone_ancient_rock'));
blacklist('thermalfoundation:material', 1);
blacklist('thermalfoundation:material', 64);
blacklist('thermalfoundation:material', 65);
blacklist('thermalfoundation:material', 66);
blacklist('thermalfoundation:material', 67);
blacklist('thermalfoundation:material', 68);
blacklist('thermalfoundation:material', 69);
blacklist('thermalfoundation:material', 70);
blacklist('thermalfoundation:material', 71);
blacklist('thermalfoundation:material', 72);
blacklist('thermalfoundation:material', 96);
blacklist('thermalfoundation:material', 97);
blacklist('thermalfoundation:material', 98);
blacklist('thermalfoundation:material', 99);
blacklist('thermalfoundation:material', 100);
infinFurnace(utils.get('thermalfoundation:material', 801), utils.get('minecraft:coal', 1));
blacklist('thermalfoundation:material', 864);
blacklist('thermalfoundation:material');
infinFurnace(utils.get('thermalfoundation:ore', 1), utils.get('thermalfoundation:material', 129));
infinFurnace(utils.get('thermalfoundation:ore', 2), utils.get('thermalfoundation:material', 130));
infinFurnace(utils.get('thermalfoundation:ore', 3), utils.get('thermalfoundation:material', 131));
infinFurnace(utils.get('thermalfoundation:ore', 4), utils.get('thermalfoundation:material', 132));
infinFurnace(utils.get('thermalfoundation:ore', 5), utils.get('thermalfoundation:material', 133));
infinFurnace(utils.get('thermalfoundation:ore', 6), utils.get('thermalfoundation:material', 134));
infinFurnace(utils.get('thermalfoundation:ore', 7), utils.get('thermalfoundation:material', 135));
infinFurnace(utils.get('thermalfoundation:ore', 8), utils.get('thermalfoundation:material', 136));
infinFurnace(utils.get('thermalfoundation:ore'), utils.get('thermalfoundation:material', 128));
infinFurnace(utils.get('threng:material', 2), utils.get('threng:material'));
blacklist('trinity:dust_au_198', W);
infinFurnace(utils.get('twilightforest:armor_shard_cluster', W), utils.get('twilightforest:knightmetal_ingot'));
infinFurnace(utils.get('twilightforest:ironwood_raw', W), utils.get('twilightforest:ironwood_ingot', 0, 2));
infinFurnace(utils.get('twilightforest:magic_beans'), utils.get('randomthings:beans', 2));
// SKIP: 'twilightforest:magic_log', W
infinFurnace(utils.get('twilightforest:raw_meef', W), utils.get('twilightforest:cooked_meef'));
infinFurnace(utils.get('twilightforest:raw_venison', W), utils.get('twilightforest:cooked_venison'));
// SKIP: 'twilightforest:twilight_log', W
/**/
