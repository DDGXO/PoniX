pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string configDir: (Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")) + "/ponix"
    readonly property string settingsPath: configDir + "/settings.json"
    readonly property string dataPath: configDir + "/data.json"

    // Settings
    property string theme: "classic" // 32 themes in themeCatalog
    property string dioramaScene: "auto" // auto or any of 200 dioramaScenes
    property string pixelScene: "auto" // auto or any of 24 aesthetic pixelScenesCatalog
    property bool glassBlur: true
    property real glassOpacity: 0.28
    property real liquidSpecular: 0.72
    property real liquidBezelScale: 1.0
    property bool dioramaPixelLiquid: false
    property string idleLook: "clock" // clock, eyes, minimal, hidden, status
    property string eyeStyle: "capsule" // 20 eye styles in eyeStyles
    property bool eyesDuringMedia: false
    property real globalEyeX: 0.0
    property real globalEyeY: 0.0
    property bool use24h: true
    property bool showLyrics: true
    property bool showRomanization: true
    property bool pinned: false
    property bool hoverExpand: true
    property bool soundsEnabled: true
    property bool hideInFullscreen: true
    property bool notchFloating: false
    property int notchGap: 6
    property string displayMode: "cursor" // cursor, selected, all
    property var enabledScreens: []
    property var detectedMonitors: []
    property string cursorMonitor: ""
    property real expandedWidth: 620
    property int dwellMs: 180
    property int collapseDelayMs: 350
    property real islandX: 0
    property int prayerRemindBefore: 10
    property var hiddenTabs: []
    property var addons: ({
        "system": false,
        "prayer": false,
        "stocks": false,
        "caffeine": false,
        "downloads": false,
        "script": false,
        "record": false,
        "notes": false,
        "health": false,
        "ielts": false,
        "servers": false,
        "agent": false,
        "audio": false,
        "clipboard": false,
        "capture": false,
        "weather": false,
        "share": false,
        "translate": false
    })

    // Data
    property var tasks: [
        { id: 1, text: "Explore PoniX on Linux", done: false },
        { id: 2, text: "Play music to see synced lyrics", done: false }
    ]
    property var shelfFiles: []
    property int focusCompleted: 0
    property var caffeineDrinks: []
    property var stocksList: ["BBCA", "BBRI", "TLKM", "ASII", "GOTO"]
    property var serversList: [
        { id: 1, name: "Cloudflare DNS", host: "1.1.1.1", port: 443, user: "", checkType: "tcp" },
        { id: 2, name: "Localhost SSH", host: "127.0.0.1", port: 22, user: "root", checkType: "tcp" }
    ]
    property var ponixAccount: ({
        connected: false,
        account: "",
        balance: 0,
        currency: "IDR",
        transactions: []
    })

    readonly property var pixelScenesCatalog: [
        { id: "auto",              label: "Auto Cycle" },
        { id: "lofi_desk",         label: "Lo-Fi Desk" },
        { id: "train_window",      label: "Train Window" },
        { id: "rainy_station",     label: "Rainy Station" },
        { id: "convenience_store", label: "Night Konbini" },
        { id: "rooftop_sunset",    label: "Rooftop Sunset" },
        { id: "windowsill_cat",    label: "Window Cat" },
        { id: "ramen_night",       label: "Ramen Stall" },
        { id: "sakura_walk",       label: "Sakura Walk" },
        { id: "neon_puddle",       label: "Neon Puddles" },
        { id: "tatami_tea",        label: "Tatami Tea" },
        { id: "balcony_night",     label: "Night Balcony" },
        { id: "laundromat",        label: "Laundromat" },
        { id: "bus_shelter",       label: "Bus Shelter" },
        { id: "bookstore",         label: "Bookshop" },
        { id: "pier_lantern",      label: "Quiet Pier" },
        { id: "beach_dusk",        label: "Twilight Shore" },
        { id: "stargaze_hill",     label: "Stargazing" },
        { id: "fireplace_cat",     label: "Hearth Cat" },
        { id: "cyclist_dusk",      label: "Dusk Cyclist" },
        { id: "shrine_steps",      label: "Shrine Steps" },
        { id: "snow_window",       label: "Snow Window" },
        { id: "cafe_corner",       label: "Corner Cafe" },
        { id: "bridge_sunset",     label: "Bridge Dusk" },
        { id: "greenhouse_nook",   label: "Plant Nook" },
        { id: "subway_platform",   label: "Subway" },
        { id: "vinyl_room",        label: "Vinyl Room" },
        { id: "attic_rain",        label: "Attic Rain" },
        { id: "river_boat",        label: "River Boat" },
        { id: "mountain_tram",     label: "Mountain Tram" },
        { id: "lantern_alley",     label: "Lantern Alley" },
        { id: "tokyo_crossing",    label: "Tokyo Cross" },
        { id: "cherry_river",      label: "Cherry River" },
        { id: "winter_street",     label: "Winter Street" },
        { id: "autumn_park",       label: "Autumn Park" },
        { id: "harbor_fog",        label: "Harbor Fog" },
        { id: "moon_temple",       label: "Moon Temple" },
        { id: "night_bakery",      label: "Night Bakery" },
        { id: "art_studio",        label: "Art Studio" },
        { id: "flower_shop",       label: "Flower Shop" },
        { id: "lighthouse_cliff",  label: "Cliff Light" },
        { id: "bamboo_path",       label: "Bamboo Path" },
        { id: "starry_camp",       label: "Starry Camp" },
        { id: "sunset_train",      label: "Sunset Train" },
        { id: "pastel_rooftop",    label: "Pastel Roof" },
        { id: "midnight_diner",    label: "Midnight Diner" },
        { id: "rainy_arcade",      label: "Rainy Street" },
        { id: "kiosk_night",       label: "Night Kiosk" },
        { id: "canal_dusk",        label: "Canal Dusk" },
        { id: "pagoda_mist",       label: "Pagoda Mist" },
        { id: "dawn_meadow",       label: "Dawn Meadow" }
    ]

    readonly property var eyeStyles: [
        { id: "capsule",     label: "Capsule" },
        { id: "terminator",  label: "Terminator" },
        { id: "sharingan",   label: "Sharingan" },
        { id: "rinnegan",    label: "Rinnegan" },
        { id: "cat",         label: "Cat Slits" },
        { id: "cyber",       label: "Cyber Visor" },
        { id: "kawaii",      label: "Kawaii" },
        { id: "angry",       label: "Angry" },
        { id: "sleepy",      label: "Sleepy" },
        { id: "heart",       label: "Heart" },
        { id: "star",        label: "Star" },
        { id: "dollar",      label: "Dollar" },
        { id: "spiral",      label: "Hypno" },
        { id: "alien",       label: "Alien" },
        { id: "cyclops",     label: "Cyclops" },
        { id: "matrix",      label: "Matrix 0/1" },
        { id: "robot",       label: "LED Bot" },
        { id: "xdead",       label: "X_X" },
        { id: "wink",        label: "Wink" },
        { id: "sus",         label: "Side-Eye" },
        { id: "vector",      label: "Vector" },
        { id: "emo",         label: "EMO Bot" },
        { id: "cozmo",       label: "Cozmo" },
        { id: "happy_arc",   label: "Happy ^ ^" },
        { id: "uwu",         label: "UwU" },
        { id: "curious",     label: "Curious" },
        { id: "shocked",     label: "Shocked" },
        { id: "dizzy",       label: "Dizzy" },
        { id: "laser",       label: "Laser" },
        { id: "demon",       label: "Demon" },
        { id: "fox",         label: "Kitsune" },
        { id: "byakugan",    label: "Byakugan" },
        { id: "mangekyo",    label: "Mangekyo" },
        { id: "geass",       label: "Geass" },
        { id: "gojo",        label: "Six Eyes" },
        { id: "sans",        label: "Sans" },
        { id: "pacman",      label: "Pac-Man" },
        { id: "invader",     label: "Invader" },
        { id: "crt",         label: "Amber CRT" },
        { id: "vapor",       label: "Vapor" },
        { id: "glitch",      label: "Glitch" },
        { id: "loading",     label: "Thinking" },
        { id: "music_note",  label: "Music" },
        { id: "fire",        label: "Flame" },
        { id: "bolt",        label: "Volt" },
        { id: "moon",        label: "Crescent" },
        { id: "sunglasses",  label: "Shades" },
        { id: "monocle",     label: "Monocle" },
        { id: "cry",         label: "Tears" },
        { id: "love_struck", label: "Love Glow" }
    ]

    readonly property var dioramaScenes: [
        { id: "auto", label: "Auto Cycle", cat: "All" },
        // 1-40 Core
        { id: "meadow", label: "Meadow", cat: "Scenery" }, { id: "rain", label: "Neon Rain", cat: "City" }, { id: "aurora", label: "Aurora", cat: "Cosmic" },
        { id: "ocean", label: "Lighthouse", cat: "Scenery" }, { id: "space", label: "Ring Planet", cat: "Cosmic" }, { id: "matrix", label: "Matrix", cat: "Game" },
        { id: "campfire", label: "Campfire", cat: "Scenery" }, { id: "sakura", label: "Torii Sakura", cat: "Scenery" }, { id: "synthgrid", label: "Synth Grid", cat: "Game" },
        { id: "cybertrain", label: "Cyber Train", cat: "City" }, { id: "fireflies", label: "Fireflies", cat: "Scenery" }, { id: "aquarium", label: "Aquarium", cat: "Scenery" },
        { id: "meteor", label: "Meteors", cat: "Cosmic" }, { id: "lightning", label: "Thunderstorm", cat: "Scenery" }, { id: "desert", label: "Desert Oasis", cat: "Scenery" },
        { id: "volcano", label: "Volcano", cat: "Scenery" }, { id: "snowcabin", label: "Snow Cabin", cat: "Scenery" }, { id: "lava", label: "Lava Lamp", cat: "Cosmic" },
        { id: "equalizer", label: "Spectrum EQ", cat: "Game" }, { id: "pacchase", label: "8-Bit Pac", cat: "Game" }, { id: "catwalk", label: "Pixel Cat", cat: "Game" },
        { id: "rocket", label: "Rocket", cat: "Cosmic" }, { id: "ufo", label: "UFO Beam", cat: "Cosmic" }, { id: "koi", label: "Koi Pond", cat: "Scenery" },
        { id: "starfield", label: "Star Warp", cat: "Cosmic" }, { id: "pyramids", label: "Pyramids", cat: "Scenery" }, { id: "radar", label: "Sonar Radar", cat: "Game" },
        { id: "dna", label: "DNA Helix", cat: "Cosmic" }, { id: "heartbeat", label: "ECG Pulse", cat: "Game" }, { id: "fireworks", label: "Fireworks", cat: "City" },
        { id: "windmill", label: "Windmill", cat: "Scenery" }, { id: "sailboat", label: "Sailboat", cat: "Scenery" }, { id: "waterfall", label: "Waterfall", cat: "Scenery" },
        { id: "invaders", label: "Invaders", cat: "Game" }, { id: "pong", label: "Pixel Pong", cat: "Game" }, { id: "snake", label: "Pixel Snake", cat: "Game" },
        { id: "clockwork", label: "Clockwork", cat: "Game" }, { id: "rainbow", label: "Rainbow", cat: "Scenery" }, { id: "eclipse", label: "Eclipse", cat: "Cosmic" },
        { id: "pendulum", label: "Pendulum", cat: "Game" },
        // 41-60 Nature Scenery
        { id: "forestglade", label: "Forest Glade", cat: "Scenery" }, { id: "mushroom", label: "Glow Shrooms", cat: "Scenery" }, { id: "autumnwind", label: "Autumn Wind", cat: "Scenery" },
        { id: "sakurariver", label: "Sakura River", cat: "Scenery" }, { id: "alpinefall", label: "Alpine Falls", cat: "Scenery" }, { id: "bamboosway", label: "Bamboo Sway", cat: "Scenery" },
        { id: "sunflowers", label: "Sunflowers", cat: "Scenery" }, { id: "caldera", label: "Caldera", cat: "Scenery" }, { id: "canyondusk", label: "Canyon Dusk", cat: "Scenery" },
        { id: "mistyfen", label: "Misty Fen", cat: "Scenery" }, { id: "gianttree", label: "Giant Tree", cat: "Scenery" }, { id: "wildflower", label: "Wildflowers", cat: "Scenery" },
        { id: "icecave", label: "Ice Cave", cat: "Scenery" }, { id: "savannah", label: "Savannah", cat: "Scenery" }, { id: "clover", label: "Clover Patch", cat: "Scenery" },
        { id: "lagoon", label: "Cave Lagoon", cat: "Scenery" }, { id: "tundra", label: "Tundra", cat: "Scenery" }, { id: "rootsystem", label: "Root System", cat: "Scenery" },
        { id: "pinefog", label: "Pine Fog", cat: "Scenery" }, { id: "fireflybrook", label: "Firefly Brook", cat: "Scenery" },
        // 61-80 Retro & Game
        { id: "arcade80s", label: "80s Arcade", cat: "Game" }, { id: "crtbedroom", label: "CRT Bedroom", cat: "Game" }, { id: "vaporbust", label: "Vaporwave", cat: "Game" },
        { id: "terminal", label: "Green Term", cat: "Game" }, { id: "cassette", label: "Cassette", cat: "Game" }, { id: "vhsstore", label: "VHS Store", cat: "City" },
        { id: "jukebox", label: "Jukebox", cat: "Game" }, { id: "handheld", label: "GameBoy", cat: "Game" }, { id: "rollerrink", label: "Roller Rink", cat: "Game" },
        { id: "drivein", label: "Drive-In", cat: "City" }, { id: "boombox", label: "Boombox", cat: "Game" }, { id: "dinersign", label: "Diner Sign", cat: "City" },
        { id: "gasstation", label: "Gas Station", cat: "City" }, { id: "loading", label: "Loading", cat: "Game" }, { id: "vinyl", label: "Vinyl Deck", cat: "Game" },
        { id: "tetris", label: "Tetromino", cat: "Game" }, { id: "breakout", label: "Breakout", cat: "Game" }, { id: "mariosky", label: "8-Bit Coins", cat: "Game" },
        { id: "crtstatic", label: "CRT Static", cat: "Game" }, { id: "laserdisc", label: "Laser Disc", cat: "Game" },
        // 81-100 Cosmic & Sci-Fi
        { id: "observatory", label: "Observatory", cat: "Cosmic" }, { id: "spacediner", label: "Space Diner", cat: "Cosmic" }, { id: "hackerden", label: "Hacker Den", cat: "City" },
        { id: "blackhole", label: "Black Hole", cat: "Cosmic" }, { id: "nebula", label: "Nebula", cat: "Cosmic" }, { id: "galaxy", label: "Spiral Galaxy", cat: "Cosmic" },
        { id: "satellite", label: "Satellite", cat: "Cosmic" }, { id: "moonbase", label: "Moon Base", cat: "Cosmic" }, { id: "mechbay", label: "Mech Bay", cat: "Game" },
        { id: "portal", label: "Warp Portal", cat: "Cosmic" }, { id: "solarflare", label: "Solar Flare", cat: "Cosmic" }, { id: "comets", label: "Twin Comets", cat: "Cosmic" },
        { id: "cyberalley", label: "Cyber Alley", cat: "City" }, { id: "holocity", label: "Holo City", cat: "City" }, { id: "spaceship", label: "Cruiser", cat: "Cosmic" },
        { id: "terraform", label: "Terraform", cat: "Cosmic" }, { id: "cryopod", label: "Cryo Pod", cat: "Cosmic" }, { id: "lasergrid", label: "Laser Grid", cat: "Game" },
        { id: "dronepatrol", label: "Drone Patrol", cat: "City" }, { id: "orbitring", label: "Orbit Ring", cat: "Cosmic" },
        // 101-120 Fantasy & Cozy
        { id: "dragonfly", label: "Dragon Flight", cat: "Game" }, { id: "knighttorch", label: "Knight Torch", cat: "Game" }, { id: "wizardtower", label: "Wizard Tower", cat: "Game" },
        { id: "alchemist", label: "Cauldron", cat: "Game" }, { id: "dungeon", label: "Dungeon", cat: "Game" }, { id: "castlebats", label: "Castle Bats", cat: "Game" },
        { id: "shrine", label: "Forest Shrine", cat: "Scenery" }, { id: "lanterns", label: "Sky Lanterns", cat: "Scenery" }, { id: "coffeeshop", label: "Rainy Cafe", cat: "City" },
        { id: "fireplace", label: "Hearth Fire", cat: "Scenery" }, { id: "greenhouse", label: "Greenhouse", cat: "Scenery" }, { id: "ramenstall", label: "Ramen Stall", cat: "City" },
        { id: "bathhouse", label: "Bathhouse", cat: "Scenery" }, { id: "trainwindow", label: "Train View", cat: "Scenery" }, { id: "atticstorm", label: "Attic Storm", cat: "Scenery" },
        { id: "library", label: "Old Library", cat: "Scenery" }, { id: "bakery", label: "Night Bakery", cat: "City" }, { id: "fairyring", label: "Fairy Ring", cat: "Scenery" },
        { id: "ghosttown", label: "Ghost Town", cat: "Scenery" }, { id: "slimecave", label: "Slime Cave", cat: "Game" },
        // 121-135 Ocean & Underwater
        { id: "coralreef", label: "Coral Reef", cat: "Scenery" }, { id: "deepangler", label: "Deep Angler", cat: "Scenery" }, { id: "shipwreck", label: "Shipwreck", cat: "Scenery" },
        { id: "whale", label: "Whale Glide", cat: "Scenery" }, { id: "jellyfish", label: "Jellyfish", cat: "Scenery" }, { id: "hydrovent", label: "Hydro Vent", cat: "Scenery" },
        { id: "atoll", label: "Tropical Atoll", cat: "Scenery" }, { id: "submarine", label: "Submarine", cat: "Scenery" }, { id: "sunkencity", label: "Sunken Ruins", cat: "Scenery" },
        { id: "mantaray", label: "Manta Ray", cat: "Scenery" }, { id: "seaturtle", label: "Sea Turtle", cat: "Scenery" }, { id: "cavediver", label: "Cave Diver", cat: "Scenery" },
        { id: "oyster", label: "Pearl Oyster", cat: "Scenery" }, { id: "octopus", label: "Octopus", cat: "Scenery" }, { id: "kelpcathedral", label: "Kelp Forest", cat: "Scenery" },
        // 136-150 City & Weather
        { id: "tokyocross", label: "Tokyo Cross", cat: "City" }, { id: "subway", label: "Subway", cat: "City" }, { id: "rooftop", label: "Rooftop Dusk", cat: "City" },
        { id: "yellowcab", label: "Yellow Cab", cat: "City" }, { id: "crane", label: "Sky Crane", cat: "City" }, { id: "nightmarket", label: "Night Market", cat: "City" },
        { id: "fireescape", label: "Fire Escape", cat: "City" }, { id: "trainbridge", label: "Rail Bridge", cat: "City" }, { id: "parkbench", label: "Park Bench", cat: "Scenery" },
        { id: "skatepark", label: "Skatepark", cat: "City" }, { id: "busstop", label: "Rain Bus Stop", cat: "City" }, { id: "pizzeria", label: "Pizzeria", cat: "City" },
        { id: "highwayjam", label: "Night Traffic", cat: "City" }, { id: "blizzard", label: "Blizzard", cat: "Scenery" }, { id: "mirage", label: "Heat Mirage", cat: "Scenery" },
        // 151-200 Aesthetic Landscapes (Pemandangan)
        { id: "lavender", label: "Lavender Dusk", cat: "Scenery" }, { id: "fjord", label: "Nordic Fjord", cat: "Scenery" }, { id: "riceterrace", label: "Rice Terrace", cat: "Scenery" },
        { id: "hotspring", label: "Hot Spring", cat: "Scenery" }, { id: "pastelcloud", label: "Pastel Clouds", cat: "Scenery" }, { id: "goldenfield", label: "Golden Field", cat: "Scenery" },
        { id: "twilightcliff", label: "Twilight Cliff", cat: "Scenery" }, { id: "moonlake", label: "Moon Lake", cat: "Scenery" }, { id: "pinevalley", label: "Pine Valley", cat: "Scenery" },
        { id: "alpineglow", label: "Alpine Glow", cat: "Scenery" }, { id: "sunsetbay", label: "Sunset Bay", cat: "Scenery" }, { id: "canyonmist", label: "Canyon Mist", cat: "Scenery" },
        { id: "cherrybridge", label: "Sakura Bridge", cat: "Scenery" }, { id: "iceberg", label: "Arctic Iceberg", cat: "Scenery" }, { id: "stargaze", label: "Stargaze Hill", cat: "Cosmic" },
        { id: "fireflylake", label: "Firefly Lake", cat: "Scenery" }, { id: "rainyvalley", label: "Rainy Valley", cat: "Scenery" }, { id: "snowpine", label: "Snowy Pines", cat: "Scenery" },
        { id: "oceanhorizon", label: "Ocean Horizon", cat: "Scenery" }, { id: "mistpeak", label: "Misty Peaks", cat: "Scenery" }, { id: "duskharbor", label: "Dusk Harbor", cat: "Scenery" },
        { id: "autumnriver", label: "Autumn River", cat: "Scenery" }, { id: "springhill", label: "Spring Hills", cat: "Scenery" }, { id: "summerbeach", label: "Summer Beach", cat: "Scenery" },
        { id: "wintermoon", label: "Winter Moon", cat: "Scenery" }, { id: "coralbay", label: "Coral Bay", cat: "Scenery" }, { id: "lotuspond", label: "Lotus Pond", cat: "Scenery" },
        { id: "redwood", label: "Redwood Dawn", cat: "Scenery" }, { id: "cliffvillage", label: "Cliff Village", cat: "Scenery" }, { id: "desertmoon", label: "Desert Moon", cat: "Scenery" },
        { id: "glacier", label: "Glacier Dawn", cat: "Scenery" }, { id: "aurorapeak", label: "Aurora Peaks", cat: "Cosmic" }, { id: "skyisland", label: "Sky Islands", cat: "Scenery" },
        { id: "cloudsea", label: "Sea of Clouds", cat: "Scenery" }, { id: "meadowbrook", label: "Meadow Brook", cat: "Scenery" }, { id: "sunsetpier", label: "Sunset Pier", cat: "Scenery" },
        { id: "bamboozen", label: "Zen Bamboo", cat: "Scenery" }, { id: "rainyforest", label: "Rainy Woods", cat: "Scenery" }, { id: "starrydune", label: "Starry Dunes", cat: "Scenery" },
        { id: "emeraldgorge", label: "Emerald Gorge", cat: "Scenery" }, { id: "ambervalley", label: "Amber Valley", cat: "Scenery" }, { id: "violetdusk", label: "Violet Dusk", cat: "Scenery" },
        { id: "rosegarden", label: "Rose Garden", cat: "Scenery" }, { id: "moongrove", label: "Moon Grove", cat: "Scenery" }, { id: "frostmeadow", label: "Frost Meadow", cat: "Scenery" },
        { id: "silverlake", label: "Silver Lake", cat: "Scenery" }, { id: "crimsoncliff", label: "Crimson Cliff", cat: "Scenery" }, { id: "jadepool", label: "Jade Pool", cat: "Scenery" },
        { id: "peachsky", label: "Peach Sky", cat: "Scenery" }, { id: "midnightsea", label: "Midnight Sea", cat: "Scenery" }
    ]

    // 32-Theme Catalog (Core, Terminal, Retro/ASCII, Vibe)
    readonly property var themeCatalog: [
        // Core & Materials (8)
        { id: "classic",   label: "Classic",      cat: "Core",     bg: "#0d0f12", card: "#121212", border: "#26282e", accent: "#0a84ff", text: "#f5f5f5", dim: "#9e9e9e", faint: "#686868", mono: false, sharp: false },
        { id: "liquid",    label: "Liquid",       cat: "Core",     bg: "transparent", card: "#121620", border: "#444c5e", accent: "#0a84ff", text: "#f8fafc", dim: "#cbd5e1", faint: "#94a3b8", mono: false, sharp: false },
        { id: "diorama",   label: "Diorama",      cat: "Core",     bg: "#111626", card: "#1c233b", border: "#334155", accent: "#38bdf8", text: "#f1f5f9", dim: "#94a3b8", faint: "#64748b", mono: false, sharp: false },
        { id: "pixel",     label: "Pixel Art",    cat: "Retro",    bg: "#12101e", card: "#1b1730", border: "#8b5cf6", accent: "#a78bfa", text: "#f5f3ff", dim: "#a5b4fc", faint: "#6366f1", mono: false, sharp: true  },
        { id: "glass",     label: "Glass",        cat: "Core",     bg: "#0c0e12", card: "#1a1d24", border: "#343944", accent: "#38bdf8", text: "#f8fafc", dim: "#94a3b8", faint: "#64748b", mono: false, sharp: false },
        { id: "pill",      label: "Pill",         cat: "Core",     bg: "#000000", card: "#0c0c0c", border: "#222222", accent: "#ffffff", text: "#ffffff", dim: "#a3a3a3", faint: "#666666", mono: false, sharp: false },
        { id: "ascii",     label: "ASCII",        cat: "Retro",    bg: "#070b07", card: "#0d140d", border: "#22c55e", accent: "#4ade80", text: "#4ade80", dim: "#22c55e", faint: "#15803d", mono: true,  sharp: true  },

        // Developer & Terminal Aesthetics (10)
        { id: "tokyo",     label: "Tokyo Night",  cat: "Terminal", bg: "#1a1b26", card: "#24283b", border: "#414868", accent: "#7aa2f7", text: "#c0caf5", dim: "#9aa5ce", faint: "#565f89", mono: false, sharp: false },
        { id: "catppuccin",label: "Catppuccin",   cat: "Terminal", bg: "#1e1e2e", card: "#313244", border: "#45475a", accent: "#cba6f7", text: "#cdd6f4", dim: "#a6adc8", faint: "#6c7086", mono: false, sharp: false },
        { id: "kanagawa",  label: "Kanagawa",     cat: "Terminal", bg: "#1f1f28", card: "#2a2a37", border: "#54546d", accent: "#7e9cd8", text: "#dcd7ba", dim: "#c8c093", faint: "#727169", mono: false, sharp: false },
        { id: "dracula",   label: "Dracula",      cat: "Terminal", bg: "#282a36", card: "#343746", border: "#6272a4", accent: "#bd93f9", text: "#f8f8f2", dim: "#bfbfd0", faint: "#6272a4", mono: false, sharp: false },
        { id: "nord",      label: "Nord",         cat: "Terminal", bg: "#2e3440", card: "#3b4252", border: "#4c566a", accent: "#88c0d0", text: "#eceff4", dim: "#d8dee9", faint: "#7b88a1", mono: false, sharp: false },
        { id: "gruvbox",   label: "Gruvbox",      cat: "Terminal", bg: "#282828", card: "#3c3836", border: "#665c54", accent: "#fabd2f", text: "#ebdbb2", dim: "#d5c4a1", faint: "#928374", mono: false, sharp: false },
        { id: "rosepine",  label: "Rose Pine",    cat: "Terminal", bg: "#191724", card: "#26233a", border: "#524f67", accent: "#ebbcba", text: "#e0def4", dim: "#908caa", faint: "#6e6a86", mono: false, sharp: false },
        { id: "solarized", label: "Solarized",    cat: "Terminal", bg: "#002b36", card: "#073642", border: "#2aa198", accent: "#268bd2", text: "#eee8d5", dim: "#93a1a1", faint: "#586e75", mono: false, sharp: false },
        { id: "monokai",   label: "Monokai",      cat: "Terminal", bg: "#272822", card: "#383830", border: "#75715e", accent: "#a6e22e", text: "#f8f8f2", dim: "#cfcfc2", faint: "#75715e", mono: false, sharp: false },
        { id: "everforest",label: "Everforest",   cat: "Terminal", bg: "#272e33", card: "#374145", border: "#56635f", accent: "#a7c080", text: "#d3c6aa", dim: "#9da9a0", faint: "#7a8478", mono: false, sharp: false },

        // Retro / CRT / ASCII (6)
        { id: "matrix",    label: "Matrix",       cat: "Retro",    bg: "#020904", card: "#07170b", border: "#00ff41", accent: "#00ff41", text: "#86efac", dim: "#4ade80", faint: "#166534", mono: true,  sharp: true  },
        { id: "amber",     label: "Amber CRT",    cat: "Retro",    bg: "#120b02", card: "#1f1404", border: "#ffb000", accent: "#ffb000", text: "#ffd580", dim: "#e59400", faint: "#8a5a00", mono: true,  sharp: true  },
        { id: "phosphor",  label: "Green CRT",    cat: "Retro",    bg: "#031006", card: "#081c0d", border: "#33ff66", accent: "#33ff66", text: "#99ffb3", dim: "#4ade80", faint: "#166534", mono: true,  sharp: true  },
        { id: "c64",       label: "C64 Blue",     cat: "Retro",    bg: "#1e1b6e", card: "#2a2788", border: "#7c70da", accent: "#a49bff", text: "#e0ddff", dim: "#b8b2ff", faint: "#7c70da", mono: true,  sharp: true  },
        { id: "gameboy",   label: "GameBoy",      cat: "Retro",    bg: "#0f380f", card: "#1b4d1b", border: "#8bac0f", accent: "#9bbc0f", text: "#cadc9f", dim: "#8bac0f", faint: "#557a1f", mono: true,  sharp: true  },
        { id: "cyber",     label: "Cyberpunk",    cat: "Retro",    bg: "#0b0a14", card: "#161426", border: "#fcee0a", accent: "#00f0ff", text: "#f8fafc", dim: "#cbd5e1", faint: "#64748b", mono: false, sharp: true  },

        // Modern Design & Atmospheric Vibes (8)
        { id: "synthwave", label: "Synthwave",    cat: "Vibe",     bg: "#1a102b", card: "#261740", border: "#ff7edb", accent: "#36f9f6", text: "#ffffff", dim: "#e2b8ff", faint: "#8b6aa8", mono: false, sharp: false },
        { id: "vaporwave", label: "Vaporwave",    cat: "Vibe",     bg: "#180d26", card: "#25143b", border: "#ff71ce", accent: "#01cdfe", text: "#fffb96", dim: "#b967ff", faint: "#7c4dff", mono: false, sharp: false },
        { id: "carbonmint",label: "Carbon Mint",  cat: "Vibe",     bg: "#14181a", card: "#1e2427", border: "#00ffc2", accent: "#00ffc2", text: "#f1f5f9", dim: "#94a3b8", faint: "#64748b", mono: false, sharp: false },
        { id: "biolum",    label: "Biolum",       cat: "Vibe",     bg: "#0a1128", card: "#132046", border: "#00e5e5", accent: "#ff6b8b", text: "#e0f2fe", dim: "#93c5fd", faint: "#475569", mono: false, sharp: false },
        { id: "sakura",    label: "Sakura",       cat: "Vibe",     bg: "#1b1018", card: "#291824", border: "#f472b6", accent: "#fb7185", text: "#fdf2f8", dim: "#f9a8d4", faint: "#9d4edd", mono: false, sharp: false },
        { id: "crimson",   label: "Crimson",      cat: "Vibe",     bg: "#140709", card: "#240c10", border: "#ef4444", accent: "#f87171", text: "#fef2f2", dim: "#fca5a5", faint: "#991b1b", mono: false, sharp: false },
        { id: "gold",      label: "Obsidian Gold",cat: "Vibe",     bg: "#100e09", card: "#1c1810", border: "#eab308", accent: "#facc15", text: "#fefce8", dim: "#fde047", faint: "#854d0e", mono: false, sharp: false },
        { id: "eink",      label: "E-Ink Paper",  cat: "Vibe",     bg: "#f4f1ea", card: "#e8e3d9", border: "#27272a", accent: "#18181b", text: "#18181b", dim: "#52525b", faint: "#71717a", mono: false, sharp: false }
    ]

    readonly property var activeTheme: {
        for (var i = 0; i < themeCatalog.length; i++) {
            if (themeCatalog[i].id === theme) return themeCatalog[i];
        }
        return themeCatalog[0];
    }

    readonly property string fontFamily: activeTheme.mono ? "monospace" : "Outfit, sans-serif"
    readonly property color colBg: activeTheme.bg
    readonly property color colCard: activeTheme.card
    readonly property color colBorder: activeTheme.border
    readonly property color colText: activeTheme.text
    readonly property color colTextDim: activeTheme.dim
    readonly property color colTextFaint: activeTheme.faint
    readonly property color colSurface: theme === "eink" ? "rgba(24, 24, 27, 0.08)" : "rgba(255, 255, 255, 0.09)"
    readonly property color colSurfaceHover: theme === "eink" ? "rgba(24, 24, 27, 0.16)" : "rgba(255, 255, 255, 0.17)"
    readonly property color colAccent: activeTheme.accent

    readonly property color colGreen: "#30D158"
    readonly property color colOrange: "#FF9F0A"
    readonly property color colRed: "#FF453A"
    readonly property color colPurple: "#BF5AF2"
    readonly property color colYellow: "#FFD60A"

    readonly property bool isFloating: theme === "pill" || notchFloating

    function isAddonOn(name) {
        return !!root.addons[name];
    }

    function toggleAddon(name) {
        var copy = Object.assign({}, root.addons);
        copy[name] = !copy[name];
        root.addons = copy;
        saveSettings();
    }

    function isTabHidden(name) {
        return root.hiddenTabs.indexOf(name) >= 0;
    }

    function toggleTabHidden(name) {
        var list = root.hiddenTabs.slice();
        var idx = list.indexOf(name);
        if (idx >= 0) list.splice(idx, 1);
        else list.push(name);
        root.hiddenTabs = list;
        saveSettings();
    }

    function detectMonitors() {
        if (!monitorDetectProc.running) {
            monitorDetectProc.running = true;
        }
    }

    function toggleScreen(screenName) {
        var list = root.enabledScreens.slice();
        var idx = list.indexOf(screenName);
        if (idx >= 0) {
            if (list.length > 1) list.splice(idx, 1); // keep at least 1
        } else {
            list.push(screenName);
        }
        root.enabledScreens = list;
        root.displayMode = "selected";
        saveSettings();
    }

    function shouldShowOnScreen(screenName) {
        if (root.displayMode === "all") return true;
        if (root.displayMode === "cursor") {
            if (root.cursorMonitor.length > 0) return screenName === root.cursorMonitor;
            if (root.detectedMonitors.length > 0) return screenName === root.detectedMonitors[0].name;
            return true;
        }
        if (root.enabledScreens.length === 0) {
            if (root.detectedMonitors.length > 0) return screenName === root.detectedMonitors[0].name;
            return true;
        }
        return root.enabledScreens.indexOf(screenName) >= 0;
    }

    Process {
        id: monitorDetectProc
        command: ["hyprctl", "monitors", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var arr = JSON.parse(text);
                    if (Array.isArray(arr)) {
                        var list = [];
                        var focusedName = "";
                        for (var i = 0; i < arr.length; i++) {
                            var m = arr[i];
                            list.push({
                                name: m.name,
                                width: m.width,
                                height: m.height,
                                x: m.x,
                                y: m.y,
                                scale: m.scale || 1,
                                focused: !!m.focused
                            });
                            if (m.focused) focusedName = m.name;
                        }
                        root.detectedMonitors = list;
                        if (root.cursorMonitor.length === 0 && list.length > 0) {
                            root.cursorMonitor = focusedName || list[0].name;
                        }
                        if (root.enabledScreens.length === 0 && list.length > 0) {
                            root.enabledScreens = [focusedName || list[0].name];
                        }
                    }
                } catch(e) {}
            }
        }
    }

    Timer {
        interval: root.idleLook === "eyes" ? 150 : 280
        repeat: true
        running: (root.displayMode === "cursor" && root.detectedMonitors.length > 1) || root.idleLook === "eyes"
        onTriggered: {
            if (!cursorPosProc.running) {
                cursorPosProc.running = true;
            }
        }
    }

    Process {
        id: cursorPosProc
        command: ["hyprctl", "cursorpos", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var pt = JSON.parse(text);
                    var cx = pt.x;
                    var cy = pt.y;
                    for (var i = 0; i < root.detectedMonitors.length; i++) {
                        var m = root.detectedMonitors[i];
                        var mw = m.width / (m.scale || 1);
                        var mh = m.height / (m.scale || 1);
                        if (cx >= m.x && cx < (m.x + mw) && cy >= m.y && cy < (m.y + mh)) {
                            if (root.cursorMonitor !== m.name) {
                                root.cursorMonitor = m.name;
                            }
                            var nx = ((cx - (m.x + mw * 0.5)) / Math.max(1, mw * 0.5));
                            var ny = ((cy - (m.y + 18)) / Math.max(1, mh * 0.5));
                            root.globalEyeX = Math.max(-1.0, Math.min(1.0, nx));
                            root.globalEyeY = Math.max(-0.4, Math.min(1.0, ny));
                            break;
                        }
                    }
                } catch(e) {}
            }
        }
    }

    function addTransaction(desc, amount, type) {
        var acc = Object.assign({}, root.ponixAccount);
        var txns = (acc.transactions || []).slice();
        txns.unshift({
            id: Date.now(),
            desc: desc,
            amount: amount,
            type: type || "out",
            date: "Just now"
        });
        acc.transactions = txns;
        acc.balance = type === "in" ? (acc.balance + amount) : (acc.balance - amount);
        root.ponixAccount = acc;
        saveData();
    }

    function saveSettings() {
        var obj = {
            theme: root.theme,
            dioramaScene: root.dioramaScene,
            pixelScene: root.pixelScene,
            glassBlur: root.glassBlur,
            glassOpacity: root.glassOpacity,
            liquidSpecular: root.liquidSpecular,
            liquidBezelScale: root.liquidBezelScale,
            dioramaPixelLiquid: root.dioramaPixelLiquid,
            idleLook: root.idleLook,
            eyeStyle: root.eyeStyle,
            eyesDuringMedia: root.eyesDuringMedia,
            use24h: root.use24h,
            showLyrics: root.showLyrics,
            showRomanization: root.showRomanization,
            pinned: root.pinned,
            hoverExpand: root.hoverExpand,
            soundsEnabled: root.soundsEnabled,
            hideInFullscreen: root.hideInFullscreen,
            notchFloating: root.notchFloating,
            notchGap: root.notchGap,
            displayMode: root.displayMode,
            enabledScreens: root.enabledScreens,
            expandedWidth: root.expandedWidth,
            dwellMs: root.dwellMs,
            collapseDelayMs: root.collapseDelayMs,
            islandX: root.islandX,
            hiddenTabs: root.hiddenTabs,
            addons: root.addons
        };
        var json = JSON.stringify(obj, null, 2);
        saveProc.command = ["sh", "-c", "mkdir -p \"$1\" && cat << 'EOF' > \"$2\"\n" + json + "\nEOF", "_", root.configDir, root.settingsPath];
        saveProc.running = true;
    }

    function saveData() {
        var obj = {
            tasks: root.tasks,
            shelfFiles: root.shelfFiles,
            focusCompleted: root.focusCompleted,
            caffeineDrinks: root.caffeineDrinks,
            stocksList: root.stocksList,
            serversList: root.serversList,
            ponixAccount: root.ponixAccount
        };
        var json = JSON.stringify(obj, null, 2);
        saveDataProc.command = ["sh", "-c", "mkdir -p \"$1\" && cat << 'EOF' > \"$2\"\n" + json + "\nEOF", "_", root.configDir, root.dataPath];
        saveDataProc.running = true;
    }

    Process {
        id: saveProc
    }

    Process {
        id: saveDataProc
    }

    Process {
        id: loadProc
        command: ["sh", "-c", "test -f \"$1\" && cat \"$1\" || echo ''", "_", root.settingsPath]
        stdout: StdioCollector {
            onStreamFinished: {
                var data = text.trim();
                if (!data || data.length === 0) return;
                try {
                    var s = JSON.parse(data);
                    if (s.theme) root.theme = s.theme;
                    if (s.dioramaScene) root.dioramaScene = s.dioramaScene;
                    if (s.pixelScene) root.pixelScene = s.pixelScene;
                    if (s.glassBlur !== undefined) root.glassBlur = s.glassBlur;
                    if (s.glassOpacity !== undefined) root.glassOpacity = s.glassOpacity;
                    if (s.liquidSpecular !== undefined) root.liquidSpecular = s.liquidSpecular;
                    if (s.liquidBezelScale !== undefined) root.liquidBezelScale = s.liquidBezelScale;
                    if (s.dioramaPixelLiquid !== undefined) root.dioramaPixelLiquid = s.dioramaPixelLiquid;
                    if (s.idleLook) root.idleLook = s.idleLook;
                    if (s.eyeStyle) root.eyeStyle = s.eyeStyle;
                    if (s.eyesDuringMedia !== undefined) root.eyesDuringMedia = s.eyesDuringMedia;
                    if (s.use24h !== undefined) root.use24h = s.use24h;
                    if (s.showLyrics !== undefined) root.showLyrics = s.showLyrics;
                    if (s.showRomanization !== undefined) root.showRomanization = s.showRomanization;
                    if (s.pinned !== undefined) root.pinned = s.pinned;
                    if (s.hoverExpand !== undefined) root.hoverExpand = s.hoverExpand;
                    if (s.soundsEnabled !== undefined) root.soundsEnabled = s.soundsEnabled;
                    if (s.hideInFullscreen !== undefined) root.hideInFullscreen = s.hideInFullscreen;
                    if (s.notchFloating !== undefined) root.notchFloating = s.notchFloating;
                    if (s.notchGap !== undefined) root.notchGap = s.notchGap;
                    if (s.displayMode) root.displayMode = s.displayMode;
                    if (s.enabledScreens) root.enabledScreens = s.enabledScreens;
                    if (s.expandedWidth) root.expandedWidth = s.expandedWidth;
                    if (s.dwellMs) root.dwellMs = s.dwellMs;
                    if (s.collapseDelayMs) root.collapseDelayMs = s.collapseDelayMs;
                    if (s.islandX !== undefined) root.islandX = s.islandX;
                    if (s.hiddenTabs) root.hiddenTabs = s.hiddenTabs;
                    if (s.addons) root.addons = Object.assign({}, root.addons, s.addons);
                } catch(e) {}
            }
        }
    }

    Process {
        id: loadDataProc
        command: ["sh", "-c", "test -f \"$1\" && cat \"$1\" || echo ''", "_", root.dataPath]
        stdout: StdioCollector {
            onStreamFinished: {
                var data = text.trim();
                if (!data || data.length === 0) return;
                try {
                    var d = JSON.parse(data);
                    if (d.tasks) root.tasks = d.tasks;
                    if (d.shelfFiles) root.shelfFiles = d.shelfFiles;
                    if (d.focusCompleted !== undefined) root.focusCompleted = d.focusCompleted;
                    if (d.caffeineDrinks) root.caffeineDrinks = d.caffeineDrinks;
                    if (d.stocksList) root.stocksList = d.stocksList;
                    if (d.serversList) root.serversList = d.serversList;
                    if (d.ponixAccount) root.ponixAccount = d.ponixAccount;
                } catch(e) {}
            }
        }
    }

    Component.onCompleted: {
        loadProc.running = true;
        loadDataProc.running = true;
        detectMonitors();
    }
}
