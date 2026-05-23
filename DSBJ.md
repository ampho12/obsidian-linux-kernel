
- High speed cameras in laser drilling for accurate 2d mapping and feature matching
- Vibration simulation: abacus or ansys


Vibration simulation software options

Server Insertion Automation Approaches

Five main technical approaches discussed for server rack insertion:

- Telescoping fork - extendable mechanism, can start prototyping immediately
- Suction cup system - for ceiling gantry setup, but structural concerns about server support material underneath

- Need to verify if servers can handle suction forces
- Could enable ceiling-mounted gantry system

- Conveyor belt approach - low confidence due to tight error margins
    - Server unsupported during roll-off, requires perfect rail alignment
    - High risk of damage if vision system misses alignment

- Ceiling gantry with cage - stationary robot option as fallback
    - Easier implementation but less generalizable
    - Could serve as demo/iteration before mobile solution

- 2-meter platform with omniballs - simple sliding mechanism
    - Server rests on platform, slides into rack on omni-directional balls
    - Provides compliance for final alignment while maintaining vision control

Vision System & Alignment Requirements

Critical technology for all approaches - high-speed camera with precision alignment:

- Current customer (SuperMicro) can position AGV within 1-2cm using ground tape
- End effector must handle final alignment within 10-20mm travel range
- Server load specs: 500 lbs force (need clarification if mass vs force)
- Existing server lift (SL500FX) supports this load as design target
- Vision pipeline becomes key differentiator for handling SKU variability vs fixed waypoint systems

Manufacturing Partnership & Capabilities

Speaker C offers comprehensive manufacturing support:

- Custom structural parts and sub-assemblies
- China-based sourcing for cost optimization on US-expensive components
- Autonomous forklift platforms available for integration testing
- High-speed camera sourcing and vision system components
- Connection to Dolphin Star for precision manufacturing
- Introduction to EBots (Foxconn supplier) for fine dexterity automation reference

Next Steps

Rishabh/Team:

- Provide tolerance specifications and technical requirements document
- Define experiments to run for each approach
- Send eBay rail link for supplier sourcing
- Confirm 500 lbs specification (mass vs force) with Steven

Speaker C:

- Source autonomous forklift pricing and availability
- Find high-speed camera suppliers and components
- Get sample/single-unit pricing for platform prototyping
- Arrange EBots introduction for dexterity automation insights
- Connect with Dolphin Star once tolerance specs available