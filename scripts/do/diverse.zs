/*

Add "diversing" recipe that require many different items
and if you provide more diversity in those items you need less of them

*/

#reloadable
#modloaded ctintegration
#priority 2000

import crafttweaker.data.IData;
import crafttweaker.item.IIngredient;
import crafttweaker.item.IItemStack;
import crafttweaker.recipes.ICraftingInfo;

function getRecipeFunction(result as IItemStack) as function(IItemStack[string])IItemStack {
  return function (ins as IItemStack[string]) as IItemStack {
    if (isNull(ins) || isNull(result)) return null;
    val ins0 = ins['0'];

    // Just skip craft if singularity already fully charged
    if (isNull(ins0) || (ins0 has result && ins0.damage <= 0)) return null;

    val newMap = {} as int[string];
    var length = 0;

    // Add already existing values
    if (!isNull(ins0.tag.singularity) && !isNull(ins0.tag.singularity.asMap())) {
      for fuel, value in ins0.tag.singularity.asMap() {
        newMap[fuel] = value;
        length += 1;
      }
    }

    // Add new values
    for i in 1 .. 9 {
      val insi = ins[i];
      if (isNull(insi)) continue; // case for manual func usage
      val amount = 1 /* insi.amount */;
      val key = insi.definition.id ~ ':' ~ insi.damage;
      if (isNull(newMap[key])) {
        newMap[key] = amount;
        length += 1;
      }
      else {
        newMap[key] = newMap[key] as int + amount;
      }
    }

    // Calculate power
    val values = intArrayOf(length, 0);
    var i = 0;
    for _, v in newMap { values[i] = v as int; i += 1; }
    val power = getPower(values);

    val ratio = power / result.maxDamage;

    if (ratio >= 1.0) return result;

    // Create new singularity data
    var singularity = !isNull(ins0.tag.singularity) ? ins0.tag.singularity : {};
    for i, v in newMap { singularity += { [i]: v as int } as IData; }

    return result
      .updateTag({ singularity: singularity })
      .withDamage((1.0 - ratio) * result.maxDamage);
  } as function(IItemStack[string])IItemStack;
}

function addRecipe(
  recipeName as string,
  empty as IItemStack, // Empty, zero-charged base ingredient
  result as IItemStack, // Result item, fully charged
  all as IIngredient // All items that may be used as fuel
) as function(IItemStack[string])IItemStack {
  val recipeFunction = getRecipeFunction(result);

  // Actual recipe
  recipes.addShaped(recipeName, result, [
    [(empty | result.anyDamage()).marked('0'), all.marked('1'), all.marked('2')],
    [all.marked('3'), all.marked('4'), all.marked('5')],
    [all.marked('6'), all.marked('7'), all.marked('8')],
  ],
  function (out, ins, cInfo) { return recipeFunction(ins); }, null);

  return recipeFunction;
}

function getPower(amountArr as int[]) as double {
  var power = 0.0;
  for v in amountArr { power += v; }
  var diversePower = 0.0;
  for v in amountArr { diversePower += mods.ctutils.utils.Math.log10(v) / 2; }
  val diverseMult = pow(2.0, diversePower);
  power *= diverseMult;
  return power;
}

function getMapLength(map as IData) as int {
  var length = 0;
  for _ in map.asMap() { length += 1; }
  return length;
}

function getItemFromString(itemStr as string) as IItemStack {
  val split = itemStr.split(':');
  return itemUtils.getItem(split[0] ~ ':' ~ split[1], split[2] as int);
}
