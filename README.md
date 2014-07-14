# Player Effects
## Summary
This is an framework for assigning temporary status effects to players. This mod is aimed to modders and maybe interested people. This framework is a work in progress and not finished.

## Profile
* Name: Player Effects
* Short name: `playereffects`
* Current version: 0.3 (expect radical changes)
* Dependencies: None!
* Discussion page: [here](https://forum.minetest.net/viewtopic.php?f=11&t=9689)

## Information for players
This mod alone is not aimed directly at players. Briefly, the point of this mod is to help other mods to implement temporary status effects for players in a clean and consistant way.
Here is the information which may be relevant to you: Your current status effects are shown on the HUD on the right side, along with a timer which shows the time until the effect gets disabled. It is possible for the server to disable this feature entirely. Some status effects may also be hidden and are never exposed to the HUD.

You only have to install this mod iff you have a mod which implements Player Effects. Here is a list of known mods which do:

* Magic Beans—Wuzzy’s Fork [`magicbeans_w`]

## Information for server operators
By default, this mod stores the effects into the file `playereffects.mt` in the current world path every 10 seconds. On a regular server shutdown, this file is also written to. The data in this file is read when the mod is started.

It is save to delete `playereffects.mt` when the mod does currently not run. This simply erases all active and inactive effects when the server starts again.

You can disable the automatic saving in `settings.lua`.

### Configuration
Player Effects can be configured. Just edit the file `settings.lua`. You find everything you need to know in that file. Be careful to not delete the lines, just edit them.

## Information for modders
This is a framework for other mods to depend on. It provides means to define, apply and remove temporary status effects to players in a (hopefully) unobstrusive way.
A status effect is an effect for a player which changes some property of the player. This property can be practically everything. Currently, the framework supports one kind of effect, which I call “exclusive effects”. For each property (speed, gravity, whatver), there can be only one effect in place at the same time. Here are some examples for possible status effects:

* high walking speed (`speed` property)
* high jump height (`jump` property)
* low player gravity (`gravity` property)
* high player gravity (`gravity` property)
* having the X privilege granted (binary “do I have the property?” property) (yes, this is weird, but it works!)

The framework aims to provide means to define effect types and to apply and cancel effects to players. The framework aims to be a stable foundation stone. This means it needs a lot of testing.

## API documentation
### Data types
#### Effect type (`effect_type`)
An effect type is a description of what is later to be concretely applied as an effect to a player. An effect type, however, is *not* assigned to a player.

`effect_type` is a table with these fields:

* `description`: Human-readable short description of the effect. Will be exposed to the HUD, iff `hidden` is `false`.
* `groups`: A table of groups to which this effect type belongs to.
* `apply`: Function to be called when effect is applied. See `playereffects.register_effect_type`.
* `cancel`: Function to be called when effect is cancelled. See `playereffects.register_effect_type`.
* `icon`: This is optional. It can be the file name of a texture. Should have a size of 16px×16px. Will be exposed to the HUD, iff `hidden` is `false`.
* `hidden`: Iff this is false, it will not be exposed to the HUD when this effect is active.

Normally you don’t need to read or edit fields of this table. Use `playereffects.register_effect_type` to add a new effect type to Player Effects.

#### Effect group
An effect group is basically a concept. Any effect type can be member of any number of effect groups. The main point of effect groups is to find effects which affect the same property. For example, an effect which makes you faster and another effect which makes you slower both affect the same property: speed. The group for that then would be the string `"speed"`. See also `examples.lua`, which includes the effects `high_speed` and `low_speed`.

Currently, the main rule of Player Effects requires that there can only be one effect in place. Don’t worry, Player Effects already does that job for you. Back to the example: it is possible to be fast and it is possible to be slow. But it is not possible to be fast `and` slow at the same time. Player Effects ensures that by cancelling all conflicting concepts before applying a new one.

The concept of groups may be changed or extended in the future.

You can invent effect groups (like the groups in Minetest) on the fly. A group is just a string. Practically, you should use groups which other people use.

#### Effect (`effect`)
An effect is an current change of a player property (like speed, jump height, and so on). It is the realization of an effect type. All effects are temporary.

`effect` is a table with the following modding-relevant fields:

* `playername`: The name of the player to which the effect belongs to.
* `effect_id`: A globally unique identifier of the effect. It is a number and assigned automatically by Player Effects.
* `effect_type_id`: The identifier of the effect’s effect type. It is a string and assigned by `playereffects.register_effect_type`.
* `metadata`: An optional field which may contain a table with additional, modder-defined data to be “remembered” for later. The `apply` callback can set this field.

Internally, Player Effects also uses these fields:

* `start_time`: The operating system time (from `os.time()`) of when the effect has been started.
* `time_left`: The number of seconds left before the effect runs out. This number is only set when the effect starts or the effect is unfrozen because i.e. a player re-joins. You can’t use this field to blindly get the remaining time of the effect.
* `hudids`: A table of HUD IDs which belong to this effect. The fields are: `icon_id` for the HUD ID of the icon and `text_id` for the HUD ID of the description text.
* `hudpos`: The Y offset factor of the effect text and the icon.

You should normally not need to care about these internally used fields.


### Functions
#### `playereffects.register_effect_type(name, description, icon, groups, apply, cancel, hidden)`
Adds a new effect type for the Player Effects mods, so it can be later be applied to players.

##### Parameters
* `name` is the name (a string) which is internally used by the mod. Later known as `effect_type_id`. Please use only alphanumeric ASCII characters.
* `description` is the text which is exposed to the HUD and visible to the player.
* `icon`: This is optional an can be `nil`. It can be the file name of a texture. Should have a size of 16px×16px. In this case, this is the icon for the HUD. Basically this is just eye-candy. If this is `nil`, no icon is shown. The icon will be exposed to the HUD, iff `hidden` is `false`.
* `groups` is a table of strings to which the effect type is assigned to.
* `apply` is a function which takes a player object. It is the player object to which the effect is applied to. This function isused by the framework to start the effect; it should only contain the gameplay-relevant stuff, the framework does the rest for you.
* `cancel` is a function which takes an effect table. It is the effect which is to be cancelled. This function is called by the framework when the effect expires or is explicitly cancelled by other means..
* `hidden` is an optional boolean value. Idf true, the effect description and icon will not be exposed to the player HUD. Otherwise, the effect is exposed.

###### `apply` function
The `apply` function is a callback function which is called by Player Effects. Here the modder can put all the gameplay-relevant code.

`apply` takes a player object as its only argument. This is the player to which the effect is applied to.

The function may return a table. This table will be added as the field `metadata` to the resulting `effect`.

The function may return `false`. This is used to tell Player Effects that the effect could, for whatever reason, not be successfully applied. Currently, this feature is experimental and possibly broken.

The function may also return just `nil` on a normal success without metadata.

###### `cancel` function
The `cancel` function is called by Player Effects when the effect is to be cancelled. Here the modder can do all the code which is needed to revert the changes an earlier `apply` call made.

`cancel` takes an `effect` as its only argument. Remember, this `effect` may also contain a field called `metadata`, which may have been added by an earlier `apply` call.

Player Effects does not care about the return value of this function.

##### Return value
Always `nil`.

#### `playereffects.apply_effect_type(effect_type_id, duration, player)`
Attempts to apply a new effect of a certain type for a certain duration to a certain player. This function can fail, although this should rarely happen.

##### Parameters
* `effect_type_id`: The identifier of the effect type. This is the name which was used in `playereffects.register_effect_type` and always a string.
* `duration`: How long the effect. Please use only positive values and only integers.
* `player`: The player object to which the new effect should be applied to.

##### Return value
The function either returns `false` or a number. Iff the function returns `false`, the effect was not successfully applied. The function may return `false` on these occasions:

* `player` is not a valid player object
* The `apply` function of the effect type returned `false`

On success, the function returns a number. This number is the effect ID of the effect which has been just created. This effect ID can be used later, for `playereffects.cancel_effect`, for example.

#### `playereffects.cancel_effect(effect_id)`
Cancels a single effect.

##### Parameter
* `effect_id`: The effect ID of the effect which shall be cancelled.

##### Return value
Always `nil`.

#### `playereffects.cancel_effect_group(groupname, playername)`
Cancels all a player’s effects which belong to a certain group.

##### Parameters
* `groupname`: The name of the effect group (string) of which all active effects of the player shall be cancelled.
* `playername`: The name of the player to which the effects which are about to be cancelled belong to.

##### Return value
Always `nil`.

#### `playereffects.cancel_effect_type(effect_type_id, cancel_all, playername)`
Cancels one or all player effect with a certain effect type
Careful! This function has *not* been tested yet!

##### Parameters
* `effect_type_id`: Identifier of the effect type.
* `cancel_all`: Iff true, cancels all active effects with this effect type
* `playername`: Name of the player to which the effects belong to

##### Return value
Always `nil`.

#### `playereffects.get_player_effects(playername)`
Returns all active effects of a player.

##### Parameter
`playername`: The name of the player from which the effects are requested.

##### Return value
A table of all `effect`s which belong to the player. If the player does not exist, this function returns an empty table.

## Examples
This mod comes with extensive examples. The examples are currently enabled by default and will be disabled from the first stable release. See `examples.lua` to find out how they are programmed. The examples are only for demonstration purposes. They are not intended to be used in an actual game.

### Chat commands
The examples are mainly accessible with chat commands. Since this is just an example, everyone can use these examples.

#### Apply effect
These commands apply (or try to) apply an effect to you. You will get a response in the chat which give you the `effect_id` on success. On failure, the example will tell you that it failed.

* `fast`: Makes you faster for 10 seconds.
* `slow`: Makes you slower for 120s.
* `hfast`: Makes you faster for 10s. This is a hidden effect and is not exposed to the HUD.
* `highjump`: Increases your jump height for 20s.
* `fly`: Gives you the `fly` privilege for a short time. Better don’t mess around with this privilege manually when you use this.
* `blind`: Tints the whole screen black for 5 seconds. This is highly experimental and will be drawn over many existing HUD elements. In other words, prepare your HUD to be messed up.
* `null`: Tries to apply an effect which always fails. This demonstrates the failure of effects.

#### Cancel effects
* `cancelall`: Cancels all your active effects.

#### Testing
* `stresstest [number]`: Applies `number` dummy effects which don’t do anything to you. Iff omitted, `number` is assumed to be 100. This command is there to test the performance of this mod for absurdly large effect numbers.
