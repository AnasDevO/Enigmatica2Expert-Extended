#modloaded jei
#priority 1
#reloadable

import crafttweaker.block.IBlockState;
import crafttweaker.item.IIngredient;
import crafttweaker.world.IFacing;
import native.net.minecraft.util.EnumParticleTypes;

// Manually add this when adding new liquids
static fluidToBlock as string[string] = {
  stone       : 'tconstruct:molten_stone',
  base_essence: 'mysticalagradditions:molten_base_essence',
} as string[string];

// Item and respective block
//                      chance blockOutput fluidId inputId
static burntRecipes as double[IBlockState][string][string]
               = {} as double[IBlockState][string][string]$orderly;

function add(
  input as IIngredient,
  outputState as IBlockState,
  fluidId as string = 'stone',
  chance as double = 1.0,
  addAlt as bool = true
) as void {
  val inputId = input.items[0].definition.id;
  if (outputState.block.definition.id == 'minecraft:air') {
    logger.logWarning('[Burn In Fluid] Failed to add recipe since block is Air. inputId: ' ~ inputId
    ~ ' outputState: ' ~ outputState.commandString
    ~ ' fluidId: ' ~ fluidId
    ~ ' chance: ' ~ chance
    );
    return;
  }

  if (isNull(burntRecipes[inputId])) burntRecipes[inputId] = {};
  if (isNull(burntRecipes[inputId][fluidId])) burntRecipes[inputId][fluidId] = {};
  burntRecipes[inputId][fluidId][outputState] = chance;

  // Add alternative high-tech recipe
  if (addAlt) {
    val sturdity = getBlockSturdity(outputState);
    scripts.processWork.work(['ARCrystallizer'], null,
      [input * ((1.0 / chance) as int * 8)], [<liquid:ic2construction_foam> * 8000],
      [scripts.do.portal_spread.utils.stateToItem(outputState) * 8], null, null, null, { energy: 20000 * sturdity, time: 10 * sturdity });
  }
}

// Get roughtly how difficult is to harvest a block
// Used for approximate time / power usage of alternative methods
function getBlockSturdity(state as IBlockState) as double {
  val def = state.block.definition;
  return (pow(max(0, def.hardness), 0.5) + 1) * (max(0, def.getHarvestLevel(state)) + 1);
}

// This function should be called once
// warding `/ct reload`
function postInit() as void {
  for inputId, tuple in burntRecipes {
    val item = itemUtils.getItem(inputId);
    if (isNull(item)) {
      logger.logWarning('[Burn In Fluid] Cannot find item for input: ' ~ inputId);
      continue;
    }
    for fluidId, stateChance in tuple {
      for state, chance in stateChance {
        val f = game.getLiquid(fluidId);
        scripts.lib.tooltip.desc.both(
          item,
          chance >= 1.0 ? 'burn_in_fluid' : 'burn_in_fluid_chance',
          item.displayName,
          f.displayName
        );

        val blockAsItem = itemUtils.getItem(state.block.definition.id, state.meta);
        if (isNull(blockAsItem)) {
          logger.logWarning('[Burn In Fluid] Cannot convert block to item <' ~ state.block.definition.id ~ ':' ~ state.meta ~ '>');
          continue;
        }
        scripts.jei.crafting_hints.fill(
          item * ((1.0 / chance + 0.00001) as int),
          f * 1000,
          blockAsItem
        );
      }
    }
  }
}

events.onEntityItemDeath(function (e as mods.zenutils.event.EntityItemDeathEvent) {
  val world = e.item.world;
  if (world.remote) return;

  if (e.damageSource.damageType != 'onFire') return;

  val entityItem = e.item;
  if (isNull(entityItem.item)) return;

  val result = burntRecipes[entityItem.item.definition.id];
  if (isNull(result)) return;

  // Iterate block essence inside and under it (item can jump)
  for i in 0 .. 2 {
    // Get state
    val blockPos = entityItem.position.getOffset(down, i);
    val blockState = world.getBlockState(blockPos);

    // Liquid should be full
    if (blockState.meta != 0) continue;

    for fluid, stateChance in result {
      for state, chance in stateChance {
        if (blockState.block.definition.id != fluidToBlock[fluid]) continue;

        val total = chance * entityItem.item.amount as double;
        if (total < 1.0 && total < world.random.nextDouble()) {
          // Conversion failure
          (world.native as native.net.minecraft.world.WorldServer)
            .spawnParticle(EnumParticleTypes.FALLING_DUST, entityItem.x, entityItem.y + 0.5, entityItem.z, 6, 0.1, 0.4, 0.1, 0.0, 0);
          continue;
        }

        // Replace block
        world.destroyBlock(blockPos, false);
        world.setBlockState(state, blockPos);
        return;
      }
    }
  }
});
