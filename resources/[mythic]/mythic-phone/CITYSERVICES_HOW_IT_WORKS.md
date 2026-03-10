# City Services App - How It Works

## Overview

The City Services app is a real-time business directory that automatically displays all active businesses on your FiveM server. Players can see which businesses are currently open and how many employees are on duty.

## Architecture

### **Flow Diagram**
```
Player Opens App
      V
UI sends NUI callback
      V
Client forwards to Server
      V
Server loops through all online players
      V
Checks Player(src).state.onDuty
      V
Gets job data from mythic-jobs
      V
Counts employees per job
      V
Returns business list to Client
      V
Client sends to UI
      V
UI displays business cards
```

## Components

### **1. Client Side** (`client/apps/cityservices.lua`)

**Purpose:** Bridge between UI and Server

```lua
-- Registers NUI callback
RegisterNUICallback('CityServices:GetBusinesses', function(data, cb)
    -- Forwards request to server
    Callbacks:ServerCallback('Phone:CityServices:GetBusinesses', {}, function(businesses)
        -- Sends response back to UI
        cb(businesses)
    end)
end)
```

**What it does:**
- Listens for UI requests
- Forwards to server
- Returns server response to UI

---

### **2. Server Side** (`server/apps/cityservices.lua`)

**Purpose:** Fetch and process business data

```lua
Callbacks:RegisterServerCallback("Phone:CityServices:GetBusinesses", function(source, data, cb)
    local onlineJobs = {}
    
    -- Loop through all online players
    for _, player in pairs(Fetch:All()) do
        local onDuty = Player(src).state.onDuty
        
        if onDuty then
            local jobData = Jobs:Get(onDuty)
            
            -- Track employee count
            onlineJobs[jobData.Id].EmployeeCount = onlineJobs[jobData.Id].EmployeeCount + 1
            
            -- Special handling for police workplaces
            if onDuty == "police" then
                local workplace = Player(src).state.onDutyWorkplace
                onlineJobs[jobData.Id].Workplaces[workplace] = count + 1
            end
        end
    end
    
    cb(businesses)
end)
```

**What it does:**
- Loops through all online players
- Checks if player is on duty (`Player(src).state.onDuty`)
- Gets job data from `mythic-jobs` system
- Counts employees per job
- Special tracking for police departments (LSPD, BCSO, SASP)
- Excludes certain jobs (EMS, government, prison)
- Returns array of active businesses

**Data Structure Returned:**
```lua
{
    {
        Id = "burger_shot",
        Name = "Burger Shot",
        Type = "Restaurant",
        Owner = 1001,
        EmployeeCount = 5
    },
    {
        Id = "police",
        Name = "Police",
        Type = "Government",
        EmployeeCount = 12,
        Workplaces = {
            lspd = 5,    -- 5 officers
            lscso = 4,   -- 4 deputies
            sasp = 3     -- 3 troopers
        }
    }
}
```

---

### **3. UI Side** (`ui/src/Apps/cityservices/`)

#### **index.jsx** - Main App Component

**Features:**
- Fetches business data on mount
- Search functionality
- Refresh button with loading state
- "Last updated" timestamp
- Empty state handling

**Key Functions:**
```javascript
// Fetch businesses from server
const fetchBusinesses = async () => {
    let res = await Nui.send('CityServices:GetBusinesses');
    setBusinesses(res);
    setLastUpdated(new Date());
};

// Time ago display
const getTimeAgo = (date) => {
    const seconds = Math.floor((new Date() - date) / 1000);
    if (seconds < 60) return 'Just now';
    const minutes = Math.floor(seconds / 60);
    if (minutes < 60) return `${minutes}m ago`;
    const hours = Math.floor(minutes / 60);
    return `${hours}h ago`;
};
```

#### **BusinessCard.jsx** - Individual Business Display

**Features:**
- Icon detection based on job ID
- Category labeling
- Employee count display
- Special police workplace breakdown

**Key Functions:**
```javascript
// Detects appropriate icon for business
const getBusinessIcon = (type, jobId) => {
    if (jobId.includes('mechanic')) return 'wrench';
    if (jobId.includes('burger')) return 'utensils';
    if (jobId.includes('bar')) return 'martini-glass';
    // ... more patterns
    return 'briefcase'; // default
};

// Determines business category
const getBusinessType = (type, jobId) => {
    if (jobId.includes('mechanic')) return 'Mechanic';
    if (jobId.includes('restaurant')) return 'Restaurant';
    // ... more patterns
    return 'Business'; // default
};

// Police workplace colors
const getWorkplaceColor = (workplaceId) => {
    return {
        lspd: '#4A90E2',   // Blue
        lscso: '#8B6F47',  // Brown
        sasp: '#9E9E9E'    // Grey
    }[workplaceId];
};
```

---

## Data Flow Example

### **Scenario:** Player opens City Services app

1. **UI (index.jsx):**
   ```javascript
   useEffect(() => {
       fetchBusinesses(); // Called on mount
   }, []);
   ```

2. **Client (cityservices.lua):**
   ```lua
   -- Receives NUI callback
   RegisterNUICallback('CityServices:GetBusinesses', ...)
   -- Forwards to server
   Callbacks:ServerCallback('Phone:CityServices:GetBusinesses', ...)
   ```

3. **Server (cityservices.lua):**
   ```lua
   -- Loops through players
   for _, player in pairs(Fetch:All()) do
       -- Checks on duty status
       if Player(src).state.onDuty then
           -- Counts employees
           EmployeeCount = EmployeeCount + 1
       end
   end
   -- Returns data
   cb(businesses)
   ```

4. **Client → UI:**
   ```lua
   cb(businesses) -- Sends to UI
   ```

5. **UI Renders:**
   ```javascript
   {businesses.map(business => (
       <BusinessCard business={business} />
   ))}
   ```

---

## Special Features

### **1. Police Department Tracking**

Instead of showing "12 Employees", police shows:
```
🛡️ 5 Officers   (Blue - LSPD)
🛡️ 4 Deputies   (Brown - BCSO)
🛡️ 3 Troopers   (Grey - SASP)
```

**How it works:**
- Server checks `Player(src).state.onDutyWorkplace`
- Tracks count per workplace (lspd, lscso, sasp)
- UI displays with color-coded breakdown

### **2. Real-Time Updates**

- Refresh button fetches latest data
- Shows spinning icon while loading
- Updates "Last updated" timestamp
- No automatic polling (manual refresh only)

### **3. Search Functionality**

- Client-side filtering (no server calls)
- Searches business names
- Case-insensitive
- Instant results

### **4. Automatic Job Detection**

- No manual configuration needed
- Pulls from `mythic-jobs` automatically
- Any job with on-duty players appears
- Icon/category detection via pattern matching

---

## Requirements

- **mythic-base** - Player state management
- **mythic-jobs** - Job system
- **mythic-phone** - Phone framework
- **FontAwesome** - Icons (already in mythic-phone)

---

## State Management

### **Server State Used:**
```lua
Player(src).state.onDuty          -- Current job ID
Player(src).state.onDutyWorkplace -- Police workplace (lspd/lscso/sasp)
```

### **UI State:**
```javascript
const [businesses, setBusinesses] = useState([]);     // Business list
const [loading, setLoading] = useState(true);         // Initial load
const [refreshing, setRefreshing] = useState(false);  // Refresh state
const [search, setSearch] = useState('');             // Search query
const [lastUpdated, setLastUpdated] = useState(null); // Timestamp
```

---

## Performance Considerations

1. **Server-side loop** - Loops through all online players
   - Optimized: Only runs on request (not continuous)
   - Scales with player count

2. **Client-side search** - No server calls for filtering
   - Instant results
   - No network overhead

3. **No auto-refresh** - Manual refresh only
   - Reduces server load
   - User controls updates

---

## Extensibility

### **Adding New Business Types:**
See `CITYSERVICES_GUIDE.md`

### **Adding New Features:**
- **Click to call:** Add phone number to business data
- **Business hours:** Track open/close times
- **Locations:** Add GPS coordinates
- **Ratings:** Player reviews/ratings
- **Auto-refresh:** Add polling interval

---

## Troubleshooting

### **No businesses showing:**
- Check if players are on duty: `Player(src).state.onDuty`
- Verify job exists in `mythic-jobs`
- Check server console for errors

### **Wrong employee count:**
- Verify on duty state is set correctly
- Check if job is excluded in server code

### **Police workplaces not showing:**
- Verify `Player(src).state.onDutyWorkplace` is set
- Check workplace ID matches (lspd/lscso/sasp)

---

## Credits

Built for Mythic Framework FiveM servers.
