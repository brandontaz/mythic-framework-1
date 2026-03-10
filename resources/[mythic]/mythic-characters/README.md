<div align="center">

![Banner](https://r2.fivemanage.com/b8BG4vav9CjKMUdz6iKnY/mythic_banner_old.png)

# mythic-characters

### *Character selection, creation & spawn system*

**Modern UI • Interactive Map • State-Aware Spawning**

![Lua](https://img.shields.io/badge/-Lua_5.4-2C2D72?style=for-the-badge&logo=lua&logoColor=white)
![FiveM](https://img.shields.io/badge/-FiveM-F40552?style=for-the-badge)
![MongoDB](https://img.shields.io/badge/-MongoDB-47A248?style=for-the-badge&logo=mongodb&logoColor=white)
![React](https://img.shields.io/badge/-React_18-61DAFB?style=for-the-badge&logo=react&logoColor=black)
![Redux](https://img.shields.io/badge/-Redux-764ABC?style=for-the-badge&logo=redux&logoColor=white)
![MUI](https://img.shields.io/badge/-Material_UI-007FFF?style=for-the-badge&logo=mui&logoColor=white)
![Webpack](https://img.shields.io/badge/-Webpack_5-8DD6F9?style=for-the-badge&logo=webpack&logoColor=black)

[Features](#-features) • [Config](#-configuration) • [Commands](#-commands)

</div>

---

## 📖 Overview

Handles the full character lifecycle — splash screen, character creation, selection, and spawning into the world. Uses an interactive GTA V map with world-to-screen coordinate conversion for spawn point selection. Character data auto-saves to MongoDB every ~10 minutes.

---

## 📸 Previews

<div align="center">

### Splash Screen
![Splash](https://r2.fivemanage.com/b8BG4vav9CjKMUdz6iKnY/Multicharacter_Previews/splash_redesign.png)

### Character Selection
![Characters](https://r2.fivemanage.com/b8BG4vav9CjKMUdz6iKnY/Multicharacter_Previews/characters_redesign.png)

### Character Creation
![Character Creation](https://r2.fivemanage.com/DYU0chgxzWP85xodo3Oc8/Screenshot2026-03-05220135.png)

### Spawn Selector
![Spawn Selector](https://r2.fivemanage.com/b8BG4vav9CjKMUdz6iKnY/Multicharacter_Previews/spawn_redesign.png)

</div>

---

## ✨ Features

<div align="center">
<table>
<tr>
<td width="50%">

### Characters
- **Splash Screen** — Animated intro with server branding
- **Selection** — Collapsible list with State ID, phone, jobs, last played
- **Creation** — Name, gender, DOB, origin, biography
- **Auto-Save** — Persisted to MongoDB every ~10 minutes

</td>
<td width="50%">

### Spawning
- **Interactive Map** — GTA V world map with location pins
- **Smart Icons** — Spawn markers with labels
- **State-Aware** — Jailed → prison, ICU → hospital, new → apartment
- **Dynamic Locations** — Extra spawns loaded from MongoDB

</td>
</tr>
</table>
</div>

<div align="center">
<table>
<tr>
<td width="50%">

### UI
- **Dark Theme** — Teal accents, floating orbs, subtle grid
- **Glass Effects** — Frosted cards with scanline overlays
- **Animations** — Card reveals, logo glow, smooth transitions
- **Clean Typography** — Orbitron + Rajdhani font pairing

</td>
<td width="50%">

### Backend
- **Reputation System** — Leveled tracking with XP thresholds
- **Fetch Extensions** — CharacterData, SID, ID lookups
- **Admin Commands** — Logout, rep, permissions
- **Middleware** — Full Mythic component lifecycle

</td>
</tr>
</table>
</div>

---

## ⚙️ Configuration

`config.lua`

```lua
Config = {
    NewSpawn     = { ... },  -- character creation apartment
    PrisonSpawn  = { ... },  -- Bolingbroke (event: Jail:SpawnJailed)
    ICUSpawn     = { ... },  -- Mt Zonah ICU (event: Hospital:SpawnICU)
    DefaultSpawns = {        -- always available
        { id = 1, label = 'LSIA', location = { x, y, z, h } },
    },
}
```

Extra spawn points come from the `locations` collection in MongoDB (`Type = 'spawn'`).

---

## 🎮 Commands

| Command | Args | Description |
|---------|------|-------------|
| `/logout` | `<StateID>` | Force-logout a player |
| `/addrep` | `<StateID> <RepID> <Amount>` | Add reputation points |
| `/remrep` | `<StateID> <RepID> <Amount>` | Remove reputation points |
| `/phoneperm` | `<StateID> <App> <Permission>` | Toggle phone app permissions |
| `/laptopperm` | `<StateID> <App> <Permission>` | Toggle laptop app permissions |

---

## 👨‍💻 Development

```bash
cd ui
bun install
bun run dev      # dev server
bun run build    # production → ui/dist/
```

---

## 📦 Dependencies

| Resource | Why |
|----------|-----|
| `mythic-base` | Core framework |
| `mythic-pwnzor` | Anti-cheat |

---

## 🤝 Credits

<div align="center">
<table>
<tr>
<td align="center" width="50%">
<h3>UI Redesign</h3>
<b>Brandon</b>
</td>
<td align="center" width="50%">
<h3>Framework</h3>
<b>Alzar</b>
</td>
</tr>
</table>
</div>

---

<div align="center">

[![Made for FiveM](https://img.shields.io/badge/Made_for-FiveM-F40552?style=for-the-badge)](https://fivem.net)
[![Mythic Framework](https://img.shields.io/badge/Mythic-Framework-208692?style=for-the-badge)](https://github.com/mythic-framework)

</div>
