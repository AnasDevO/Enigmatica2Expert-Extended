#modloaded contenttweaker
#reloadable
#ignoreBracketErrors
#priority -100

import crafttweaker.entity.IEntity;
import crafttweaker.item.IIngredient;
import crafttweaker.item.IItemStack;
import crafttweaker.player.IPlayer;
import crafttweaker.world.IBlockPos;
import crafttweaker.world.IFacing;
import crafttweaker.world.IWorld;
import mods.contenttweaker.BlockPos;
import mods.contenttweaker.BlockState;
import mods.contenttweaker.MutableItemStack;
import mods.contenttweaker.World;
import native.net.minecraft.util.EnumParticleTypes;

function abs(n as double) as double { return n < 0 ? -n : n; }

// ------------------------------------------
// Anglesite and Benitoite
// ------------------------------------------
<cotBlock:ore_anglesite>.dropHandler = function (drops, world, position, state, fortune) {
  drops.clear();
  drops.add(<contenttweaker:anglesite>);
  for i in 0 .. fortune { drops.add(<contenttweaker:anglesite> % 50); }
};

<cotBlock:ore_benitoite>.dropHandler = function (drops, world, position, state, fortune) {
  drops.clear();
  drops.add(<contenttweaker:benitoite>);
  for i in 0 .. fortune { drops.add(<contenttweaker:benitoite> % 50); }
};

// ------------------------------------------
// Conglomerates
// ------------------------------------------
function getPlayer(world as IWorld, p as IBlockPos) as IPlayer {
  for pl in world.getAllPlayers() {
    if (abs(pl.x - p.x) > 60 || abs(pl.y - p.y) > 60 || abs(pl.z - p.z) > 60) continue;
    return pl;
  }
  return null;
}

function createParticles(world as IWorld, p as IBlockPos, type as EnumParticleTypes, amount as int = 10) as void {
  if (world.remote) return;
  (world.native as native.net.minecraft.world.WorldServer)
    .spawnParticle(type, 0.5 + p.x, 0.5 + p.y, 0.5 + p.z, amount, 0.25, 0.25, 0.25, 0.02, 0);
}

val lifeRecipes = {
  'betteranimalsplus:goose': { <betteranimalsplus:golden_goose_egg>: 100 },
  'minecraft:ocelot'       : { <actuallyadditions:item_hairy_ball>: 4 },
} as int[IItemStack][string];

<cotBlock:conglomerate_of_life>.onBlockPlace = function (world, p, blockState) {
  if (!world.remote) scripts.do.build.entity.build(world, p, blockState);
  createParticles(world, p, EnumParticleTypes.HEART);
};
<cotBlock:conglomerate_of_life>.onBlockBreak = function (world, p, blockState) { createParticles(world, p, EnumParticleTypes.HEART); };
<cotBlock:conglomerate_of_life>.onRandomTick = function (world, p, blockState) {
  if (world.remote) return;
  for entity in world.getEntities() {
    if (isNull(entity.definition)) continue;
    val output = lifeRecipes[entity.definition.id];
    if (isNull(output)) continue;
    if (abs(entity.x - p.x) > 8 || abs(entity.y - p.y) > 8 || abs(entity.z - p.z) > 8) continue;

    for outItem, outChance in output {
      if (world.getRandom().nextInt(outChance) != 1) continue;
      val w as IWorld = world;
      val itemEntity = (outItem * 1).createEntityItem(w, entity.x as float, entity.y as float, entity.z as float);
      itemEntity.motionY = 0.4;
      world.spawnEntity(itemEntity);
      createParticles(world, p, EnumParticleTypes.HEART, 3);
    }
  }
};

<cotBlock:conglomerate_of_sun>.onBlockPlace = function (world, p, blockState) {
  if (!world.remote) scripts.do.build.entity.build(world, p, blockState);
  createParticles(world, p, EnumParticleTypes.END_ROD, 10);
};
<cotBlock:conglomerate_of_sun>.onBlockBreak = function (world, p, blockState) { createParticles(world, p, EnumParticleTypes.END_ROD, 10); };
<cotBlock:conglomerate_of_sun>.onRandomTick = function (world, p, blockState) {
  if (world.remote) return;
  var hadEffect = false;
  for entity in world.getEntities() {
    if (isNull(entity.definition)) continue;
    if (!(entity instanceof crafttweaker.entity.IEntityAgeable)) continue;
    val ageable as crafttweaker.entity.IEntityAgeable = entity;

    // Already grown up
    if (ageable.growingAge >= 0) continue;

    // Speed up growth of ageble mobs
    ageable.addGrowth(300);
    hadEffect = true;
    createParticles(world, ageable.position, EnumParticleTypes.END_ROD, 10);
  }
  if (hadEffect) createParticles(world, p, EnumParticleTypes.END_ROD, 10);
};

// ------------------------------------------
// Coral
// ------------------------------------------
function canPlaceCoral(world as World, p as IBlockPos) as bool {
  val floorBlockId = world.getBlockState(p.down()).block.definition.id;
  return
    (floorBlockId == 'minecraft:sand' || floorBlockId == 'minecraft:gravel' || floorBlockId == 'minecraft:dirt')
    && world.getBlockState(p).block.definition.id == 'minecraft:water'
    && world.getBlockState(p.up()).block.definition.id == 'minecraft:water'
  ;
}
<cotBlock:compressed_coral>.onRandomTick = function (world as World, p as BlockPos, blockState as BlockState) {
  if (world.remote) return;

  if(world.getBlockState(p.up()).block.definition.id != 'minecraft:water') {
    world.destroyBlock(p, false);
    world.setBlockState(<blockstate:randomthings:biomestone>, p);
    return;
  }

  for face in [east, north, west, south] as IFacing[] {
    if (world.getRandom().nextInt(2) != 0) continue;

    val coral = <blockstate:biomesoplenty:coral>;
    val newPos = p.getOffset(face, 1);
    if (canPlaceCoral(world, newPos)) {
      world.setBlockState(coral, newPos);
      val iworld as IWorld = world;
      (iworld.native as native.net.minecraft.world.WorldServer)
        .spawnParticle(EnumParticleTypes.WATER_DROP, 0.5 + p.x, 0.5 + p.y, 0.5 + p.z, 100, 0.5, 0.5, 0.5, 0.0, 0);
    }
  }
};

// ------------------------------------------
// Singularities
// ------------------------------------------
// Pairs of x:y coords sorted by distance from 0:0
static slotSurroundings as int[] = [
  0, 0, 0, 1, 0, -1, 1, 0, -1, 0, 1, 1, -1, 1, 1, -1, -1, -1,
  0, 2, 0, -2, 2, 0, -2, 0, 1, 2, -1, 2, 1, -2, -1, -2, 2, 1,
  -2, 1, 2, -1, -2, -1, 2, 2, -2, 2, 2, -2, -2, -2, 0, 3, 0,
  -3, 3, 0, -3, 0, 1, 3, -1, 3, 1, -3, -1, -3, 3, 1, -3, 1, 3,
  -1, -3, -1, 2, 3, -2, 3, 2, -3, -2, -3, 3, 2, -3, 2, 3, -2,
  -3, -2, 4, 0, -4, 0, 4, 1, -4, 1, 4, -1, -4, -1, 3, 3, -3,
  3, 3, -3, -3, -3, 4, 2, -4, 2, 4, -2, -4, -2, 4, 3, -4, 3,
  4, -3, -4, -3, 5, 0, -5, 0, 5, 1, -5, 1, 5, -1, -5, -1, 5,
  2, -5, 2, 5, -2, -5, -2, 5, 3, -5, 3, 5, -3, -5, -3, 6, 0,
  -6, 0, 6, 1, -6, 1, 6, -1, -6, -1, 6, 2, -6, 2, 6, -2, -6,
  -2, 6, 3, -6, 3, 6, -3, -6, -3, 7, 0, -7, 0, 7, 1, -7, 1, 7,
  -1, -7, -1, 7, 2, -7, 2, 7, -2, -7, -2, 7, 3, -7, 3, 7, -3,
  -7, -3, 8, 0, -8, 0, 8, 1, -8, 1, 8, -1, -8, -1, 8, 2, -8,
  2, 8, -2, -8, -2, 8, 3, -8, 3, 8, -3, -8, -3,
] as int[];

// Return slot index based on x:y coordinates
// Assume that first hotbar slot is 0:0
function coordToSlot(x as int, y as int) as int {
  return y == 0 ? x : (x + (4 - y) * 9);
}

function slotToCoord(slot as int) as int[] {
  return slot < 9 ? [slot, 0] : [slot % 9, 4 - slot / 9];
}

function getSingularityUpdateFunc(
  allIngredients as IIngredient,
  recipeFunction as function(IItemStack[string])IItemStack
) as function(MutableItemStack,World,IEntity,int,bool)void {
  return function(stack as MutableItemStack, world as World, owner as IEntity, slot as int, isSelected as bool) as void {

    // skip each second frame to prevent item duping
    if (world.provider.worldTime % 2 == 0) return;

    // Singularity already charged
    if (stack.damage <= 0) return;

    if (!(owner instanceof IPlayer)) {
      // TODO: simple iteration in fake player's inventories
      // Problem - non-player inventories doesnt have `getInventoryStack()` function
      return;
    }

    val player as IPlayer = owner;

    val xy = slotToCoord(slot);
    val x = xy[0];
    val y = xy[1];

    var consumed = 0;
    var result = stack as IItemStack;
    for i in 0 .. slotSurroundings.length / 2 {
      val u = x + slotSurroundings[i * 2];
      val v = y + slotSurroundings[i * 2 + 1];
      if (0 > u || u > 8 || 0 > v || v > 3) continue;

      val nextSlot = coordToSlot(u, v);

      val item = player.getInventoryStack(nextSlot);

      // Check if valid fuel for singularity
      if (isNull(item) || !(allIngredients has item)) continue;

      // Consume item
      // player.replaceItemInInventory(nextSlot, null);
      item.mutable().shrink(1);

      result = recipeFunction({ '0': result, '1': item });
      consumed += 1;
      if (result.damage <= 0 || consumed >= 4) break;
    }

    // Set item result
    if (consumed > 0) player.replaceItemInInventory(slot, result);
  };
}

<cotItem:fish_singularity>.onItemUpdate = getSingularityUpdateFunc(<ore:listAllfishraw>, scripts.cot.recipes.fishRecipeFunction);
<cotItem:woodweave_singularity>.onItemUpdate = getSingularityUpdateFunc(<ore:plankFireproof>, scripts.cot.recipes.woodweaveRecipeFunction);
// ------------------------------------------
