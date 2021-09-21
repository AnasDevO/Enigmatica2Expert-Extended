/**
 * @file Create MODS.md
 * 
 * @author Krutoy242
 * @link https://github.com/Krutoy242
 */

//@ts-check

const fs = require('fs')
const curseforge = require('mc-curseforge-api')
const {injectInFile} = require('../lib/utils.js')
const _ = require('lodash')
const {mod_loadTime_typles} = require('./benchmark.js')


const getModsIds = module.exports.getModsIds = function (json_Path_A, json_Path_B) {
  const A = JSON.parse(fs.readFileSync(json_Path_A, 'utf8')).installedAddons
  const B = JSON.parse(fs.readFileSync(json_Path_B, 'utf8')).installedAddons
  const union = _.uniqBy([...B, ...A], 'addonID')
  const map_A = {}; A.forEach(e=>map_A[e.addonID] = e)
  const map_B = {}; B.forEach(e=>map_B[e.addonID] = e)
  const map_union = {}; union.forEach(e=>map_union[e.addonID] = e)

  const result = {
    map_A,
    map_B,
    union,
    map_union,
    both:    B.filter(o => map_A[o.addonID]),
    added:   B.filter(o =>!map_A[o.addonID]),
    removed: A.filter(o =>!map_B[o.addonID]),
    updated: null,
  }
  result.updated = B.filter(o => map_A[o.addonID] && map_A[o.addonID].installedFile?.id !== o.installedFile?.id)
  return result
}

function getLogo(logo) {
  const url = logo?.thumbnailUrl
  if(!url) return

  // Example of url:
  // https://media.forgecdn.net/avatars/thumbnails/5/796/256/256/635351433944342580.png
  // return url.replace(/(media\.forgecdn\.net\/avatars\/thumbnails\/\d+\/\d+\/)\d+\/\d+/, '$1'+'64/64')
  return url
}

const loadTimeSumm = _.sumBy(mod_loadTime_typles, '1')
const exceptionsList = [
  'Just Enough Items (JEI)',
  'Tinkers Construct',
  'CraftTweaker'
]
function getSquare(modName) {
  if(exceptionsList.includes(modName)) return '🟪'
  
  const loadTime = mod_loadTime_typles.find(([m])=>m===modName)?.[1]

  if (isNaN(loadTime)) return '🟫'

  const rate = loadTime / loadTimeSumm

  if(rate < 0.0001) return '🟩'
  if(rate < 0.001 ) return '🟨'
  if(rate < 0.01  ) return '🟧'
  if(rate >=0.01  ) return '🟥'
}

const formatRow = module.exports.formatRow = function (mcAddon, curseAddon, options={}) {
  const name = curseAddon.name.trim()
  return (options.asList?'- ':'') + 
  (options.noIcon?'':`<img src="${getLogo(curseAddon.logo)}" width="50"> | ${getSquare(name)} `)+
  `[**${name}**](${curseAddon.url}) `+
  `<sup>${options.isUpdated?' 🟡 ':''}<sub>${mcAddon?.installedFile?.FileNameOnDisk}</sub></sup>`+
  (options.noSummary?'':` <br> ${curseAddon.summary}`)
}


function formatTable(rows) {
  return [
    `${rows.length} mods in this section.`,
    '',
    'Icon | Summary',
    '----:|:-------',
    ...rows
  ].join('\n')
}

const init = module.exports.init = async function() {
  const diff = getModsIds('../Enigmatica 2 Expert - E2E (unchanged, updated)/minecraftinstance.json', 'minecraftinstance.json')

  // Debug cutoff
  // diff.union = diff.union.slice(-30)

  console.log(`  💟 Asking Curseforge API for ${diff.union.length} mods ...`)

  const cursedUnion = await Promise.all(diff.union.map(mcAddon=>curseforge.getMod(mcAddon.addonID)))
  
  console.log(`  💟 Curseforge API returns ${cursedUnion.length} mods ...`)
  cursedUnion.sort((a,b) => b.downloads - a.downloads)

  
  fs.writeFileSync(
    'CurseForge_example_return.json',
    JSON.stringify(cursedUnion, null, 2)
  )

  let result = {
    BOTH:     cursedUnion.filter(({id}) => diff.map_A[id] && diff.map_B[id]),
    EXTENDED: cursedUnion.filter(({id}) =>!diff.map_A[id] && diff.map_B[id]),
    REMOVED:  cursedUnion.filter(({id}) => diff.map_A[id] &&!diff.map_B[id]),
  }

  for (const [key, rawList] of Object.entries(result)) {
    const rows = rawList.map(curseAddon=>{
      const isUpdated = key==='BOTH' && diff.updated.some(o=>o.addonID===curseAddon.id)
      return formatRow(diff.map_union[curseAddon.id], curseAddon, {isUpdated})
    })

    injectInFile('MODS.md', 
      `<!-- Automatic generated list ${key} -->\n`,
      '\n<!-- End of list -->',
      formatTable(rows)
    )
  }
}


if(require.main === module) init()