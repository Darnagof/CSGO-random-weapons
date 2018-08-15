DEBUG <- true;

IncludeScript("vs_rand/loadouts.nut", this);

function debugPrint(text){
    if(DEBUG == false)
        return;
    printl(text);
}

function GiveRandomLoadout(){
    local weaponGiver = Entities.FindByName(null, "weapon_giver");
    local specialToGive = [];
    debugPrint("game_player_equip found :"+ weaponGiver.GetName());

    // Regular weapons giving ----------
    local chosenLoadout = _loadouts[RandomInt(0, _loadouts.len()-1)];
    for(local i = 0; i < chosenLoadout.len(); i++){
        //If grenade (because can't give more than 1 of the same grenade type with game_player_equip)
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

        while ((player = Entities.FindByModel(player, "models/player/custom_player/legacy/ctm_st6.mdl")) != null){
            debugPrint("Found player !");
            players.push(player);
        }
        while ((player = Entities.FindByModel(player, "models/player/custom_player/legacy/tm_phoenix.mdl")) != null){
            debugPrint("Found player !");
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
}