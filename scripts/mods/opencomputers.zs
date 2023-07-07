#modloaded opencomputers

# Make robot easy to break and replace
<opencomputers:robot>.hardness = 0.5;
<opencomputers:cable>.hardness = 0.05;

# [Battery Upgrade (Tier 2)] from [Simple Machine Parts][+2]
craft.remake(<opencomputers:upgrade:2>, ["pretty",
  ": □ :",
  "□ S □",
  ": □ :"], {
  ":": <ore:oc:capacitor>,          # Capacitor
  "□": <ore:plateElectrum>,         # Electrum Plate
  "S": <ore:itemSimpleChassiParts>, # Simple Machine Parts
});

# [Battery Upgrade (Tier 3)] from [Machine Parts][+2]
craft.remake(<opencomputers:upgrade:3>, ["pretty",
  ": □ :",
  "□ C □",
  ": □ :"], {
  ":": <ore:oc:capacitor>,    # Capacitor
  "□": <ore:platePlatinum>,
  "C": <ore:itemChassiParts>, # Machine Parts
});

# [Geolyzer] from [Microchip (Tier 2)][+2]
craft.remake(<opencomputers:geolyzer>, ["pretty",
  "B : B",
  "B c B",
  "B : B"], {
  "B": <ore:stoneBasalt>, # Basalt
  ":": <ore:oc:materialCircuitBoardPrinted>, # Printed Circuit Board (PCB)
  "c": <ore:oc:circuitChip2>,                # Microchip (Tier 2)
});

# [Tractor Beam Upgrade] from [Sticky Piston][+2]
craft.remake(<opencomputers:upgrade:25>, [
  "I",
  "P",
  ":"], {
  "I": <cyclicmagic:magnet_block>,           # Item Magnet
  "P": <ore:craftingPiston>,                 # Sticky Piston
  ":": <ore:oc:materialCircuitBoardPrinted>, # Printed Circuit Board (PCB)
});

# [Chamelium]*8 from [Latex Bucket][+2]
recipes.removeByRecipeName("opencomputers:material54");
craft.make(<opencomputers:material:28> * 8, ["pretty",
  "▲ P ▲",
  "P ~ P",
  "▲ P ▲"], {
  "▲": <ore:dust>,          # Dust
  "P": <biomesoplenty:ash>, # Pile of Ashes
  "~": <fluid:latex> * 1000, # Latex Bucket
});

# [Angel Upgrade] from [Angel Block][+1]
craft.remake(<opencomputers:upgrade>, [
  ":■:"], {
  ":": <ore:oc:circuitChip1>,    # Microchip (Tier 1)
  "■": <extrautils2:angelblock>, # Angel Block
});

# [Computer Case (Tier 1)] from [Cabinet][+4]
craft.remake(<opencomputers:case1>, ["pretty",
  "I c I",
  "□ C □",
  "I : I"], {
  "I": <ore:barsIron>,                       # Iron Bars
  "c": <ore:oc:circuitChip1>,                # Microchip (Tier 1)
  "□": <ore:plateCopper>,                    # Copper Plate
  "C": <rustic:cabinet>,                     # Cabinet
  ":": <ore:oc:materialCircuitBoardPrinted>, # Printed Circuit Board (PCB)
});

# [Computer Case (Tier 2)] from [Bronze Storage Box][+4]
craft.remake(<opencomputers:case2>, ["pretty",
  "S : S",
  "□ B □",
  "S m S"], {
  "S": <ore:itemSimpleChassiParts>,          # Simple Machine Parts
  ":": <ore:oc:circuitChip2>,                # Microchip (Tier 2)
  "□": <ore:plateConstantan>,                # Constantan Plate
  "B": <ore:chest>,
  "m": <ore:oc:materialCircuitBoardPrinted>, # Printed Circuit Board (PCB)
});

# [Computer Case (Tier 3)] from [Steel Storage Box][+4]
craft.remake(<opencomputers:case3>, ["pretty",
  "C : C",
  "□ S □",
  "C m C"], {
  "C": <ore:itemChassiParts>,                # Machine Parts
  ":": <ore:oc:circuitChip3>,                # Microchip (Tier 3)
  "□": <ore:platePlatinum>,                  # Platinum Plate
  "S": <ic2:te:114>,                         # Steel Storage Box
  "m": <ore:oc:materialCircuitBoardPrinted>, # Printed Circuit Board (PCB)
});
