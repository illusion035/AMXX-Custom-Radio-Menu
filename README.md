# 🎮 Custom Radio Menu Plugin 🎮  
### A Customizable Radio System for Counter-Strike 1.6  

---

## 📋 Description  

This plugin replaces the default radio commands with a fully customizable radio menu.  
Players can open the menu using the standard radio buttons (`radio1`, `radio2`, `radio3`) or custom commands and send pre-configured messages to teammates or all players.

---

## 🔧 Key Features  

- **Customizable Messages** – Define your own radio messages in the configuration file  
- **Visibility Control** – Set who can see the messages (everyone, only terrorists, only counter-terrorists, or only teammates)  
- **Custom Commands** – Configure your own commands to open the radio menu  
- **Colored Chat Messages** – Messages appear with color formatting in chat  
- **Advanced Navigation Menu** – Supports an unlimited number of radio messages  

---

## ⚙️ Configuration  

Create a **`custom_radio.ini`** file inside the `configs` folder with the following format, or simply use the one from the archive:

```ini
// Custom Radio Menu Configuration

// Team visibility: 0 - All players, 1 - Terrorists only, 2 - Counter-Terrorists only, 3 - Teammates only
team_visibility = 3

// Commands to open radio menu (comma separated)
commands = radio1, radio2, radio3, say /radio

// Menu items format: Menu Item = Radio Message
Rush B = Let's rush B this round!
Need Backup = I need backup!
Spread Out = Spread out team!
Stick Together = Let's stick together team!
Save = Save your weapons for next round!
Go Go Go = Go go go!
Fallback = Fall back!
Need Drop = Can someone drop me a weapon?
```

## 📸 Screenshots  
https://i.imgur.com/qHJRwHl.png  
https://i.imgur.com/eViBbtc.png

---

## 📝 Version History  

### Version 1.0 (Initial Release)  
- First public release  
- Customizable radio messages  
- Visibility options for messages  
- Advanced navigation menu  

---

## 🔗 Requirements  

- **AMX Mod X** 1.8.2 or newer  
- **CromChat** include file  
