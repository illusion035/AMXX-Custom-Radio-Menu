#include <amxmodx>
#include <amxmisc>
#include <cromchat>

#define PLUGIN "ILLUSION PLUGINS: Custom Radio Menu"
#define VERSION "1.0"
#define AUTHOR "illusion @ CraftVision"

#define MAX_RADIO_ITEMS 32
#define MAX_COMMANDS 10
#define CONFIG_FILE "custom_radio.ini"

enum {
    TEAM_ALL = 0,
    TEAM_T = 1,
    TEAM_CT = 2,
    TEAM_TEAMMATES = 3
}

new g_radioMenuItems[MAX_RADIO_ITEMS][128]
new g_radioMessages[MAX_RADIO_ITEMS][192]
new g_radioItemsCount = 0
new g_teamVisibility = TEAM_TEAMMATES
new g_radioCommands[MAX_COMMANDS][32]
new g_radioCommandsCount = 0
new g_menuPosition[33]

stock parse_arg(const string[], pos, output[], outputLen, delimiter) {
    new i = pos
    new outputPos = 0
    new stringLen = strlen(string)
    
    while (i < stringLen && string[i] == ' ')
        i++
    
    while (i < stringLen && outputPos < outputLen - 1) {
        if (string[i] == delimiter)
            break
        
        output[outputPos++] = string[i++]
    }
    
    output[outputPos] = 0
    
    if (i == stringLen)
        return -1
    
    return i + 1
}

public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR)
    
    load_config()
    
    for (new i = 0; i < g_radioCommandsCount; i++) {
        register_clcmd(g_radioCommands[i], "cmd_radio_menu")
    }
    
    register_clcmd("radio1", "cmd_radio_menu")
    register_clcmd("radio2", "cmd_radio_menu")
    register_clcmd("radio3", "cmd_radio_menu")
    
    register_menu("Radio Menu", MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_KEY_0, "handle_radio_menu")
}

public load_config() {
    new configPath[128]
    get_configsdir(configPath, charsmax(configPath))
    formatex(configPath, charsmax(configPath), "%s/%s", configPath, CONFIG_FILE)
    
    new file = fopen(configPath, "rt")
    if (!file) {
        log_amx("Error: Could not open config file: %s", configPath)
        return
    }
    
    new line[256], key[128], value[192]
    
    while (!feof(file)) {
        fgets(file, line, charsmax(line))
        trim(line)
        
        if (line[0] == '/' && line[1] == '/' || line[0] == ';' || !line[0]) {
            continue
        }
        
        if (containi(line, "team_visibility") != -1) {
            strtok(line, key, charsmax(key), value, charsmax(value), '=')
            trim(key); trim(value)
            g_teamVisibility = str_to_num(value)
            continue
        }
        
        if (containi(line, "commands") != -1) {
            strtok(line, key, charsmax(key), value, charsmax(value), '=')
            trim(key); trim(value)
            
            new command[32], pos = 0
            while (g_radioCommandsCount < MAX_COMMANDS) {
                pos = parse_arg(value, pos, command, charsmax(command), ',')
                trim(command)
                
                if (!command[0])
                    break
                    
                copy(g_radioCommands[g_radioCommandsCount], charsmax(g_radioCommands[]), command)
                g_radioCommandsCount++
                
                if (pos == -1)
                    break
            }
            continue
        }
        
        if (contain(line, " = ") != -1 && g_radioItemsCount < MAX_RADIO_ITEMS) {
            strtok(line, key, charsmax(key), value, charsmax(value), '=')
            trim(key); trim(value)
            
            if (key[0] && value[0]) {
                copy(g_radioMenuItems[g_radioItemsCount], charsmax(g_radioMenuItems[]), key)
                copy(g_radioMessages[g_radioItemsCount], charsmax(g_radioMessages[]), value)
                g_radioItemsCount++
            }
        }
    }
    
    fclose(file)
}

public cmd_radio_menu(id) {
    if (!is_user_alive(id))
        return PLUGIN_HANDLED
    
    g_menuPosition[id] = 0
    show_radio_menu(id)
    return PLUGIN_HANDLED
}

public show_radio_menu(id) {
    if (!g_radioItemsCount) {
        CC_SendMessage(id, "&x07No radio commands configured.")
        return
    }
    
    new menuBody[512], menuKeys = 0
    new position = g_menuPosition[id]
    
    new start = position * 7
    
    if (start >= g_radioItemsCount) {
        start = g_menuPosition[id] = 0
    }
    
    new totalPages = (g_radioItemsCount / 7 + ((g_radioItemsCount % 7) ? 1 : 0))
    
    new len = formatex(menuBody, charsmax(menuBody), "\y•\r•\w• \yCustom Radio Menu \w•\r•\y•\R\d%d/%d^n^n", 
        position + 1, totalPages)
    
    new end = start + 7
    if (end > g_radioItemsCount)
        end = g_radioItemsCount
    
    for (new i = start; i < end; i++) {
        if ((i - start) % 2 == 0)
            len += formatex(menuBody[len], charsmax(menuBody) - len, "\r%d. \w%s^n", i - start + 1, g_radioMenuItems[i])
        else
            len += formatex(menuBody[len], charsmax(menuBody) - len, "\r%d. \y%s^n", i - start + 1, g_radioMenuItems[i])
            
        menuKeys |= (1 << (i - start))
    }
    
    len += formatex(menuBody[len], charsmax(menuBody) - len, "^n\y• \r• \w• \d• • • • • • \w• \r• \y•^n^n")
    
    new bool:hasNextPage = (position + 1 < totalPages)
    new bool:hasPrevPage = (position > 0)
    
    if (hasPrevPage) {
        len += formatex(menuBody[len], charsmax(menuBody) - len, "\r8. \w« \yBack^n")
        menuKeys |= MENU_KEY_8
    }
    
    if (hasNextPage) {
        len += formatex(menuBody[len], charsmax(menuBody) - len, "\r9. \yNext \w»^n")
        menuKeys |= MENU_KEY_9
    }
    
    len += formatex(menuBody[len], charsmax(menuBody) - len, "\r0. \wExit")
    menuKeys |= MENU_KEY_0
    
    show_menu(id, menuKeys, menuBody, -1, "Radio Menu")
}

public handle_radio_menu(id, key) {
    new position = g_menuPosition[id]
    new itemsPerPage = 7
    
    switch (key) {
        case 8: {
            new totalPages = (g_radioItemsCount / 7 + ((g_radioItemsCount % 7) ? 1 : 0))
            if (position + 1 < totalPages) {
                g_menuPosition[id]++
                show_radio_menu(id)
            }
            return PLUGIN_HANDLED
        }
        case 7: {
            if (position > 0) {
                g_menuPosition[id]--
                show_radio_menu(id)
            }
            return PLUGIN_HANDLED
        }
        case 9: {
            return PLUGIN_HANDLED
        }
    }
    
    new itemIndex = position * itemsPerPage + key
    
    if (itemIndex >= g_radioItemsCount)
        return PLUGIN_HANDLED
    
    send_radio_message(id, itemIndex)
    
    return PLUGIN_HANDLED
}

public send_radio_message(id, messageIndex) {
    if (!is_user_connected(id))
        return
    
    new playerName[32]
    get_user_name(id, playerName, charsmax(playerName))
    
    new playerTeam = get_user_team(id)
    new players[32], numPlayers, i
    get_players(players, numPlayers, "ch")
    
    for (i = 0; i < numPlayers; i++) {
        new targetId = players[i]
        new targetTeam = get_user_team(targetId)
        
        new bool:canSee = false
        
        switch (g_teamVisibility) {
            case TEAM_ALL: canSee = true
            case TEAM_T: canSee = (playerTeam == 1)
            case TEAM_CT: canSee = (playerTeam == 2)
            case TEAM_TEAMMATES: canSee = (playerTeam == targetTeam)
        }
        
        if (canSee) {
            CC_SendMessage(targetId, "&x03[Radio] &x04%s&x01: %s", playerName, g_radioMessages[messageIndex])
        }
    }
}
