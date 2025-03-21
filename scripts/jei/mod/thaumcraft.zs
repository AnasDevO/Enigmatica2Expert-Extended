#priority 950
#modloaded thaumcraft requious

import crafttweaker.item.IIngredient;
import crafttweaker.item.IItemStack;
import crafttweaker.item.WeightedItemStack;
import mods.requious.SlotVisual;

val x = <assembly:infernal_furnace>;
x.addJEICatalyst(<thaumcraft:infernal_furnace>);
x.setJEIDurationSlot(1, 0, 'duration', SlotVisual.arrowRight());
x.setJEIDurationSlot(2, 0, 'duration', scripts.jei.requious.getVisGauge(1, 13));
scripts.jei.requious.addInsOuts(x, [[0, 0]], [[3, 0], [4, 0], [5, 0], [6, 0]]);

val RE = <thaumcraft:nugget:10>;

function infFurLore(outs as WeightedItemStack[], i as int) as IItemStack {
  if (i >= outs.length) return null;
  return outs[i].stack.withLore(['§d§l' ~ outs[i].percent as int ~ '%']);
}

function addInfFur(input as IIngredient, outs as WeightedItemStack[]) {
  scripts.jei.requious.add(<assembly:infernal_furnace>, { [input] as IIngredient[]: [
    infFurLore(outs, 0),
    infFurLore(outs, 1),
    infFurLore(outs, 2),
    infFurLore(outs, 3),
  ] });
}

/* Inject_js(
Object.entries(
  _.groupBy(
    getCrtLogBlock('\n-Smelting Bonus:', '\n-Warp')
      .split('\n')

      // Filter unwanted ores
      .filter(s => !s.match(/yellorium/i))

      // Split into [in, out, chance]
      .map(s =>
        s.match(/--in: (.*?), out: (.*?), change: (.*)/)?.splice(1)
      )
      .filter(Boolean)

      // Unwrap wildcarded
      .flatMap(([inp, out, chance]) => {
        const id = inp.match(/<([^:]+:[^:]+):\*>/)?.[1]
        if (!id) return [[inp, out, chance]]
        return getSubMetas(id).map(meta => [
          `<${id}:${meta}>`,
          out,
          chance,
        ])
      }),
    '0'
  )
)
  // Filter only items that actually present in furnace
  .filter(([inp]) => {
    if (isPurged(inp)) return false
    const oreName = inp.match(/<ore:([^>]+)>/)?.[1]
    const items = oreName
      ? getByOredict(oreName)
      : [inp.match(/<(?<id>[^:]+:[^:>]+)(:(?<damage>\d+|\*))?>/).groups]
    return items.some(({ id, damage }) =>
      getFurnaceRecipes().some(
        fr =>
          fr.in_id === id
          && (fr.in_meta === '*'
            || Number(fr.in_meta ?? 0) === Number(damage ?? 0))
      )
    )
  })
  .map(
    ([inp, arr]) =>
      `addInfFur(${inp.padEnd(41)}, [${arr
        .map(
          ([, out, chance]) =>
            `${out.replace('<thaumcraft:nugget:10>', 'RE')
            } % ${
            (parseFloat(chance) * 100) | 0}`
        )
        .sort((a, b) => a.length - b.length)
        .join(', ')}]);`
  )
  .sort(naturalSort)
) */
addInfFur(<contenttweaker:ore_phosphor>            , [<contenttweaker:nugget_phosphor> * 2 % 50]);
addInfFur(<jaopca:thaumcraft_cluster.aluminium>           , [RE % 2, <thermalfoundation:material:196> % 33]);
addInfFur(<jaopca:thaumcraft_cluster.amber>               , [RE % 2, <jaopca:nugget.amber> % 33]);
addInfFur(<jaopca:thaumcraft_cluster.amethyst>            , [RE % 2, <jaopca:nugget.amethyst> % 33]);
addInfFur(<jaopca:thaumcraft_cluster.anglesite>           , [RE % 2]);
addInfFur(<jaopca:thaumcraft_cluster.apatite>             , [RE % 2, <jaopca:nugget.apatite> % 33]);
addInfFur(<jaopca:thaumcraft_cluster.aquamarine>          , [RE % 2, <jaopca:nugget.aquamarine> % 33]);
addInfFur(<jaopca:thaumcraft_cluster.ardite>              , [RE % 2, <tconstruct:nuggets:1> % 33]);
addInfFur(<jaopca:thaumcraft_cluster.astralstarmetal>     , [RE % 2, <jaopca:nugget.astralstarmetal> % 33]);
addInfFur(<jaopca:thaumcraft_cluster.benitoite>           , [RE % 2]);
addInfFur(<jaopca:thaumcraft_cluster.boron>               , [RE % 2, <jaopca:nugget.boron> % 33]);
addInfFur(<jaopca:thaumcraft_cluster.certusquartz>        , [RE % 2, <jaopca:nugget.certusquartz> % 33]);
addInfFur(<jaopca:thaumcraft_cluster.chargedcertusquartz> , [RE % 2, <jaopca:nugget.chargedcertusquartz> % 33]);
addInfFur(<jaopca:thaumcraft_cluster.coal>                , [RE % 2]);
addInfFur(<jaopca:thaumcraft_cluster.cobalt>              , [RE % 2, <tconstruct:nuggets> % 33]);
addInfFur(<jaopca:thaumcraft_cluster.diamond>             , [RE % 2, <thermalfoundation:material:16> % 33]);
addInfFur(<jaopca:thaumcraft_cluster.dilithium>           , [RE % 2, <jaopca:nugget.dilithium> % 33]);
addInfFur(<jaopca:thaumcraft_cluster.dimensionalshard>    , [RE % 2, <jaopca:nugget.dimensionalshard> % 33]);
addInfFur(<jaopca:thaumcraft_cluster.draconium>           , [RE % 2, <draconicevolution:nugget> % 33]);
addInfFur(<jaopca:thaumcraft_cluster.emerald>             , [RE % 2, <thermalfoundation:material:17> % 33]);
addInfFur(<jaopca:thaumcraft_cluster.iridium>             , [RE % 2, <thermalfoundation:material:199> % 33]);
addInfFur(<jaopca:thaumcraft_cluster.lapis>               , [RE % 2, <jaopca:nugget.lapis> % 33]);
addInfFur(<jaopca:thaumcraft_cluster.lithium>             , [RE % 2, <jaopca:nugget.lithium> % 33]);
addInfFur(<jaopca:thaumcraft_cluster.magnesium>           , [RE % 2, <jaopca:nugget.magnesium> % 33]);
addInfFur(<jaopca:thaumcraft_cluster.malachite>           , [RE % 2, <jaopca:nugget.malachite> % 33]);
addInfFur(<jaopca:thaumcraft_cluster.mithril>             , [RE % 2, <thermalfoundation:material:200> % 33]);
addInfFur(<jaopca:thaumcraft_cluster.nickel>              , [RE % 2, <thermalfoundation:material:197> % 33]);
addInfFur(<jaopca:thaumcraft_cluster.osmium>              , [RE % 2, <mekanism:nugget:1> % 33]);
addInfFur(<jaopca:thaumcraft_cluster.peridot>             , [RE % 2, <jaopca:nugget.peridot> % 33]);
addInfFur(<jaopca:thaumcraft_cluster.platinum>            , [RE % 2, <thermalfoundation:material:198> % 33]);
addInfFur(<jaopca:thaumcraft_cluster.quartzblack>         , [RE % 2, <jaopca:nugget.quartzblack> % 33]);
addInfFur(<jaopca:thaumcraft_cluster.redstone>            , [RE % 2]);
addInfFur(<jaopca:thaumcraft_cluster.ruby>                , [RE % 2, <jaopca:nugget.ruby> % 33]);
addInfFur(<jaopca:thaumcraft_cluster.sapphire>            , [RE % 2, <jaopca:nugget.sapphire> % 33]);
addInfFur(<jaopca:thaumcraft_cluster.tanzanite>           , [RE % 2, <jaopca:nugget.tanzanite> % 33]);
addInfFur(<jaopca:thaumcraft_cluster.thorium>             , [RE % 2, <jaopca:nugget.thorium> % 33]);
addInfFur(<jaopca:thaumcraft_cluster.titanium>            , [RE % 2, <libvulpes:productnugget:7> % 33]);
addInfFur(<jaopca:thaumcraft_cluster.topaz>               , [RE % 2, <jaopca:nugget.topaz> % 33]);
addInfFur(<jaopca:thaumcraft_cluster.trinitite>           , [RE % 2, <jaopca:nugget.trinitite> % 33]);
addInfFur(<jaopca:thaumcraft_cluster.tungsten>            , [RE % 2, <jaopca:nugget.tungsten> % 33]);
addInfFur(<jaopca:thaumcraft_cluster.uranium>             , [RE % 2, <immersiveengineering:metal:25> % 33]);
addInfFur(<jaopca:skyresources_dirty_gem.aluminium>          , [<jaopca:nugget.aquamarine> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.amber>              , [<thermalfoundation:material:16> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.amethyst>           , [<jaopca:nugget.chargedcertusquartz> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.anglesite>          , [<jaopca:nugget.dimensionalshard> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.apatite>            , [<jaopca:nugget.magnesium> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.aquamarine>         , [<thermalfoundation:material:17> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.ardite>             , [<minecraft:gold_nugget> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.astralstarmetal>    , [<jaopca:nugget.tungsten> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.benitoite>          , [<jaopca:nugget.dimensionalshard> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.boron>              , [<jaopca:nugget.lithium> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.certusquartz>       , [<thermalfoundation:material:16> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.chargedcertusquartz>, [<jaopca:nugget.topaz> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.coal>               , [<thaumcraft:nugget:9> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.cobalt>             , [<thermalfoundation:material:197> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.copper>             , [<minecraft:gold_nugget> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.diamond>            , [<jaopca:nugget.malachite> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.dilithium>          , [<jaopca:nugget.dimensionalshard> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.dimensionalshard>   , [<jaopca:nugget.peridot> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.draconium>          , [<jaopca:nugget.astralstarmetal> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.emerald>            , [<jaopca:nugget.tanzanite> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.gold>               , [<thermalfoundation:material:196> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.iridium>            , [<mekanism:nugget:1> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.iron>               , [<minecraft:gold_nugget> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.lapis>              , [<jaopca:nugget.sapphire> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.lead>               , [<thermalfoundation:material:194> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.lithium>            , [<jaopca:nugget.topaz> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.magnesium>          , [<thermalfoundation:material:192> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.malachite>          , [<thermalfoundation:material:192> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.mithril>            , [<jaopca:nugget.astralstarmetal> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.nickel>             , [<mekanism:nugget:1> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.osmium>             , [<thermalfoundation:material:198> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.peridot>            , [<thermalfoundation:material:16> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.platinum>           , [<thermalfoundation:material:199> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.quartz>             , [<thermalfoundation:material:16> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.quartzblack>        , [<jaopca:nugget.aquamarine> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.redstone>           , [<jaopca:nugget.quartzblack> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.ruby>               , [<jaopca:nugget.magnesium> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.sapphire>           , [<draconicevolution:nugget> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.silver>             , [<minecraft:gold_nugget> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.tanzanite>          , [<thermalfoundation:material:16> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.thorium>            , [<jaopca:nugget.boron> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.tin>                , [<thermalfoundation:material:195> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.titanium>           , [<jaopca:nugget.magnesium> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.topaz>              , [<thaumcraft:nugget:9> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.trinitite>          , [<jaopca:nugget.trinitite> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.tungsten>           , [<thermalfoundation:material:199> * 24 % 100]);
addInfFur(<jaopca:skyresources_dirty_gem.uranium>            , [<jaopca:nugget.lithium> * 24 % 100]);
addInfFur(<minecraft:beef>                         , [<thaumcraft:chunk> % 33]);
addInfFur(<minecraft:chicken>                      , [<thaumcraft:chunk:1> % 33]);
addInfFur(<minecraft:fish:0>                       , [<thaumcraft:chunk:3> % 33]);
addInfFur(<minecraft:fish:1>                       , [<thaumcraft:chunk:3> % 33]);
addInfFur(<minecraft:mutton>                       , [<thaumcraft:chunk:5> % 33]);
addInfFur(<minecraft:porkchop>                     , [<thaumcraft:chunk:2> % 33]);
addInfFur(<minecraft:rabbit>                       , [<thaumcraft:chunk:4> % 33]);
addInfFur(<ore:oreAluminium>                       , [RE % 1, <thermalfoundation:material:196> % 33]);
addInfFur(<ore:oreAmber>                           , [RE % 1, <jaopca:nugget.amber> % 33]);
addInfFur(<ore:oreAmethyst>                        , [RE % 1, <jaopca:nugget.amethyst> % 33]);
addInfFur(<ore:oreApatite>                         , [RE % 1, <jaopca:nugget.apatite> % 33]);
addInfFur(<ore:oreAquamarine>                      , [RE % 1, <jaopca:nugget.aquamarine> % 33]);
addInfFur(<ore:oreArdite>                          , [RE % 1, <tconstruct:nuggets:1> % 33]);
addInfFur(<ore:oreAstralStarmetal>                 , [RE % 1, <jaopca:nugget.astralstarmetal> % 33]);
addInfFur(<ore:oreBoron>                           , [RE % 1, <jaopca:nugget.boron> % 33]);
addInfFur(<ore:oreCinnabar>                        , [RE % 2, <thaumcraft:nugget:5> % 33]);
addInfFur(<ore:oreCoal>                            , [RE % 1]);
addInfFur(<ore:oreCobalt>                          , [RE % 1, <tconstruct:nuggets> % 33]);
addInfFur(<ore:oreCopper>                          , [RE % 1, <thermalfoundation:material:192> % 32]);
addInfFur(<ore:oreDiamond>                         , [RE % 2]);
addInfFur(<ore:oreDilithium>                       , [RE % 1, <jaopca:nugget.dilithium> % 33]);
addInfFur(<ore:oreEmerald>                         , [RE % 2]);
addInfFur(<ore:oreGold>                            , [RE % 2, <minecraft:gold_nugget> % 33]);
addInfFur(<ore:oreIridium>                         , [RE % 1, <thermalfoundation:material:199> % 33]);
addInfFur(<ore:oreIron>                            , [RE % 1, <minecraft:iron_nugget> % 33]);
addInfFur(<ore:oreLapis>                           , [RE % 1]);
addInfFur(<ore:oreLead>                            , [RE % 1, <thermalfoundation:material:195> % 32]);
addInfFur(<ore:oreLithium>                         , [RE % 1, <jaopca:nugget.lithium> % 33]);
addInfFur(<ore:oreMagnesium>                       , [RE % 1, <jaopca:nugget.magnesium> % 33]);
addInfFur(<ore:oreMalachite>                       , [RE % 1, <jaopca:nugget.malachite> % 33]);
addInfFur(<ore:oreMithril>                         , [RE % 1, <thermalfoundation:material:200> % 33]);
addInfFur(<ore:oreNickel>                          , [RE % 1, <thermalfoundation:material:197> % 33]);
addInfFur(<ore:oreOsmium>                          , [RE % 1, <mekanism:nugget:1> % 33]);
addInfFur(<ore:orePeridot>                         , [RE % 1, <jaopca:nugget.peridot> % 33]);
addInfFur(<ore:orePlatinum>                        , [RE % 1, <thermalfoundation:material:198> % 33]);
addInfFur(<ore:oreQuartz>                          , [RE % 1, <thaumcraft:nugget:9> % 33]);
addInfFur(<ore:oreQuartzBlack>                     , [RE % 1, <jaopca:nugget.quartzblack> % 33]);
addInfFur(<ore:oreRedstone>                        , [RE % 1]);
addInfFur(<ore:oreRuby>                            , [RE % 1, <jaopca:nugget.ruby> % 33]);
addInfFur(<ore:oreSapphire>                        , [RE % 1, <jaopca:nugget.sapphire> % 33]);
addInfFur(<ore:oreSilver>                          , [RE % 2, <thermalfoundation:material:194> % 32]);
addInfFur(<ore:oreTanzanite>                       , [RE % 1, <jaopca:nugget.tanzanite> % 33]);
addInfFur(<ore:oreThorium>                         , [RE % 1, <jaopca:nugget.thorium> % 33]);
addInfFur(<ore:oreTin>                             , [RE % 1, <thermalfoundation:material:193> % 32]);
addInfFur(<ore:oreTopaz>                           , [RE % 1, <jaopca:nugget.topaz> % 33]);
addInfFur(<ore:oreTungsten>                        , [RE % 1, <jaopca:nugget.tungsten> % 33]);
addInfFur(<ore:oreUranium>                         , [RE % 1, <immersiveengineering:metal:25> % 33]);
addInfFur(<thaumcraft:cluster:0>                   , [RE % 2]);
addInfFur(<thaumcraft:cluster:1>                   , [RE % 2, <minecraft:gold_nugget> % 33]);
addInfFur(<thaumcraft:cluster:2>                   , [RE % 2, <thaumcraft:nugget:1> % 33, <thermalfoundation:material:192> * 2 % 32]);
addInfFur(<thaumcraft:cluster:3>                   , [RE % 2, <thaumcraft:nugget:2> % 33, <thermalfoundation:material:193> * 2 % 32]);
addInfFur(<thaumcraft:cluster:4>                   , [RE % 2, <thaumcraft:nugget:3> % 33, <thermalfoundation:material:194> * 2 % 32]);
addInfFur(<thaumcraft:cluster:5>                   , [RE % 2, <thaumcraft:nugget:4> % 33, <thermalfoundation:material:195> * 2 % 32]);
addInfFur(<thaumcraft:cluster:6>                   , [RE % 2, <thaumcraft:nugget:5> % 33]);
addInfFur(<thaumcraft:cluster:7>                   , [RE % 2, <thaumcraft:nugget:9> % 33]);
addInfFur(<thaumcraft:cluster>                     , [<minecraft:iron_nugget> % 33]);
/**/

for items in [
  [<thaumcraft:crystal_aer>,
  <thaumcraft:crystal_aqua>,
  <thaumcraft:crystal_ignis>],
 [<thaumcraft:crystal_ordo>,
  <thaumcraft:crystal_perditio>,
  <thaumcraft:crystal_terra>],
 [<thaumcraft:crystal_vitium>],
] as IItemStack[][] {
  scripts.jei.crafting_hints.addInsOutsCatl([
      <forge:bucketfilled>.withTag({FluidName: "menrilresin", Amount: 1000}), null,
      null, <exnihilocreatio:block_barrel1>,
      <randomthings:spectreblock>
    ],
    items
  );
}
