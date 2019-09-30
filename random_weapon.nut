<<<<<<< HEAD
DEBUG <- false;

DoIncludeScript("vs_rand/loadouts.nut", this);
=======
DEBUG <- true;

IncludeScript("vs_rand/loadouts.nut", this);
>>>>>>> 3b5592bbc645edaa976ac016b417f360e6553d0c

function debugPrint(text){
    if(DEBUG == false)
        return;
    printl(text);
}

<<<<<<< HEAD
//Find players/bots
function FindPlayers(){
    local players = [];
    local player = null;
    while ((player = Entities.FindByClassname(player, "player")) != null){
        if(player.GetTeam() == 2 || player.GetTeam() == 3){
            debugPrint("Found player !");
            players.push(player);
        }
    }
    while ((player = Entities.FindByClassname(player, "cs_bot")) != null){
        debugPrint("Found bot player !");
        players.push(player);
    }
    return players;
}

//Strip weapons from player
function StripWeapons(player){
    local weapon = null;
    while((weapon = Entities.FindByClassname(weapon,"weapon_*")) != null){
        if (weapon.GetOwner()==player){
            weapon.Destroy();
        }
    }
}

//Give weapon to players
function GiveWeaponToPlayers(weapon, amount, players){
    debugPrint("Give to players: "+weapon+" x"+amount);
    local giver = Entities.CreateByClassname("game_player_equip");
    giver.__KeyValueFromInt("spawnflags", 1);
    giver.__KeyValueFromInt(weapon, 0);
    foreach(player in players){
        for(local i = 0; i < amount; i++){
            EntFireByHandle(giver, "Use", "", 0.0, player, null);
        }
    }
    giver.Destroy();
}

//Give P2000 to players (even if USP is in inventory)
function GiveP2000ToPlayers(amount, players){
    debugPrint("Give to players: weapon_hkp2000 x"+amount);
    local giver = Entities.FindByName(null, "hkp2000_spawner");
    foreach(player in players){
        EntFireByHandle(giver, "ForceSpawnAtEntityOrigin", "!activator", 0.0, player, null);
    }
}

function GiveTaserToPlayers(){
    activator.Destroy();
    debugPrint("Give to players: weapon_taser x1");
    local giver = Entities.FindByName(null, "taser_spawner");
    local players = FindPlayers();
    foreach(player in players){
        EntFireByHandle(giver, "ForceSpawnAtEntityOrigin", "!activator", 0.0, player, null);
    }
}

function GiveRandomLoadout(){
    //Strip all players
    local players = FindPlayers();
    for(local i = 0; i < players.len(); i++){
        StripWeapons(players[i]);
    }
    //Chose random loadout
    local chosenLoadout = loadouts[1.0 * (loadouts.len()-1) * rand() / RAND_MAX];
    // Is weapon_taser in loadout ?
    local giveTaser = false;
    //Give loadout to all players
    foreach(weapon in chosenLoadout){
        if(weapon[0] == "weapon_hkp2000"){
            GiveP2000ToPlayers(weapon[1], players);
        }else if(weapon[0] == "weapon_taser"){
            giveTaser = true;
        }else{
            GiveWeaponToPlayers(weapon[0], weapon[1], players);
        }
    }
    // Taser must be given in last
    if(giveTaser){
        local timer = Entities.CreateByClassname("logic_timer");
        EntFireByHandle(timer, "RefireTime", "1.0", 0.0, null, null);
        EntFireByHandle(timer, "AddOutput", "OnTimer random_weapon_script:RunScriptCode:GiveTaserToPlayers()", 0.0, null, null);
        EntFireByHandle(timer, "Enable", "", 0.0, null, null);
    }
    //Make melee weapons from DZ mode pickable
    EntFire("weapon_melee", "addoutput", "classname weapon_knifegg", 0.0, null);
=======
function GiveRandomLoadout(){
    local weaponGiver = Entities.FindByName(null, "weapon_giver");
    local specialToGive = [];
    debugPrint("game_player_equip found :"+ weaponGiver.GetName());

    // Regular weapons giving ----------
    local chosenLoadout = _loadouts[RandomInt(0, _loadouts.len()-1)];
    for(local i = 0; i < chosenLoadout.len(); i++){
        //If grenade (because can't give more than 1 of the same grenade type with game_player_equip)
        // or hkp2000 (because will give p2000 or usp depending of player's inventory)
        if(
        chosenLoadout[i][0] == "weapon_hegrenade" ||
        chosenLoadout[i][0] == "weapon_molotov" ||
        chosenLoadout[i][0] == "weapon_tagrenade" ||
        chosenLoadout[i][0] == "weapon_flashbang" ||
        chosenLoadout[i][0] == "weapon_smokegrenade" ||
        chosenLoadout[i][0] == "weapon_hkp2000"){
            specialToGive.push(chosenLoadout[i]);
        //Else just add regular weapon to game_player_equip
        }else{
            weaponGiver.__KeyValueFromInt(chosenLoadout[i][0], chosenLoadout[i][1]);
            debugPrint("Give to players :"+ chosenLoadout[i][0]);
        }
    }
    EntFire(weaponGiver.GetName(), "TriggerForAllPlayers", "", 0);

    // Grenades giving ----------
    if(specialToGive != null){

        //Find all players
        SendToConsoleServer("ammo_grenade_limit_default 99");
        SendToConsoleServer("ammo_grenade_limit_flashbang 99");
        SendToConsoleServer("ammo_grenade_limit_total 99");
        local players = [], player = null;

        while ((player = Entities.FindByClassname(player, "player")) != null){
            debugPrint("Found player !");
            players.push(player);
        }
        while ((player = Entities.FindByClassname(player, "cs_bot")) != null){
            debugPrint("Found bot player !");
            players.push(player);
        }

        for(local i = 0; i < specialToGive.len(); i++){
            debugPrint("Giving "+specialToGive[i][0]+" x"+specialToGive[i][1]+" for each player");
            for(local j = 0; j < players.len(); j++){
                for(local k = 0; k < specialToGive[i][1]; k++){
                    EntFire(specialToGive[i][0]+"_spawner", "ForceSpawnAtEntityOrigin", "!activator", 0, players[j]);
                }
            }
        }

    }
>>>>>>> 3b5592bbc645edaa976ac016b417f360e6553d0c
}