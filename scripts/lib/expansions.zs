#priority 5000
#ignoreBracketErrors

import crafttweaker.item.IIngredient;
import crafttweaker.item.IItemStack;
import crafttweaker.entity.IEntityDefinition;

$expand IEntityDefinition$asSoul() as IItemStack {
  // Rendering Emberoot Fairies causing crashes on AMD cards
  // Do not render fairies at all then
  // Related:
  //  https://github.com/Krutoy242/Enigmatica2Expert-Extended/commit/a5ef59c8c5d1e16c6598732e7fff14d33927ed90
  //  https://github.com/EnigmaticaModpacks/Enigmatica2Expert/issues/2079
  //  https://github.com/Lothrazar/ERZ/pull/41
  if (this.id == 'emberroot:fairies') return null;

  return <draconicevolution:mob_soul>.withTag({EntityName: this.id});
}

$expand IEntityDefinition$asEgg() as IItemStack {
  return <minecraft:spawn_egg>.withTag({EntityTag: {id: this.id}});
}

$expand IEntityDefinition$asStack() as IItemStack {
  val soul = this.asSoul();
  if (isNull(soul)) return this.asEgg();
  return soul;
}

$expand IEntityDefinition$asIngr() as IIngredient {
  val soul = this.asSoul();
  val egg = this.asEgg();
  if (isNull(soul)) return egg;
  return soul | egg;
}
