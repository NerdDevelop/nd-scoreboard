-- ==========================================
-- qb-scoreboard — config
-- Developed by: Nerd Developer
-- Website: https://nerd-developer.com
-- ==========================================

Config = {}

-- ==========================================
-- SCOREBOARD CONFIGURATION
-- ==========================================

Config.OpenKey    = 'HOME'
Config.HoldToShow = true
Config.Position   = 'rightMid'   -- 'right' | 'left' | 'rightMid' | 'leftMid'

Config.ServerName = 'Nerd'
Config.MaxPlayers = 64

-- NUI layout (Scoreboard UI)
Config.Nui = {
    PanelWidth   = 348,      -- width in px
    PanelMargin  = 26,       -- side margin in px
    PanelYOffset = 0,        -- vertical offset in px (right-mid mode)
}

-- UI language / direction
-- Set to 'ar' for Arabic (RTL)
Config.Language  = 'en'       -- 'en' | 'ar'
Config.Direction = nil        -- override: 'ltr' | 'rtl'
Config.Rtl       = nil        -- override: true | false

-- Text shown inside NUI (so you can translate without editing HTML)
Config.UI = {
    playersLabel = (Config.Language == 'ar') and 'اللاعبون' or 'Players',
    policeLabel  = (Config.Language == 'ar') and 'الشرطة'   or 'Police',
    emsLabel     = (Config.Language == 'ar') and 'الإسعاف'  or 'EMS',
    eventsTitle  = (Config.Language == 'ar') and 'الفعاليات النشطة' or 'ACTIVE EVENTS',
    footerLeft   = (Config.Language == 'ar') and '' or '',
    onlineText   = (Config.Language == 'ar') and 'أونلاين' or 'Online',
    offlineText  = (Config.Language == 'ar') and 'أوفلاين' or 'Offline',
}

-- 3D IDs فوق الرأس (تقدر تغيّر الألوان/الحجم/الارتفاع)
Config.HeadId = {
    OffsetZ = 0.38,  -- ارفع/انزل الـ ID فوق الرأس
    Scale   = 1.60,  -- كبر/صغر الرقم
    MaxDistance = 28.0,      -- أقصى مسافة لظهور الـ ID
    MinDistance = 1.0,       -- أقل مسافة (لو قريب جداً ما يطلع)
    RequireLOS  = true,      -- لازم يكون في خط نظر؟ (حاجز = ما يظهر)
    NoLOSMaxDistance = 6.0,  -- لو فيه حاجز: يظهر فقط إذا قريب (تعطيل بوضع RequireLOS = false)
    Colors  = {
        Idle    = { r = 255, g = 255, b = 255, a = 235 }, -- ساكت
        Talking = { r = 235, g =  60, b =  60, a = 255 }, -- يتكلم
    }
}

-- ==========================================
-- JOBS TO COUNT (for header stats)
-- ==========================================

Config.PoliceJobs = { 'police', 'sheriff', 'swat' }
Config.EmsJobs    = { 'ambulance', 'doctor' }

-- ==========================================
-- EVENTS / ROBBERIES LIST
-- Icons: house | bank | store | diamond | person | truck | money | star
-- ==========================================

Config.Events = {
    -- requiredPolice: كم شرطي لازم يكون متصل عشان تبان "جاهزة" (خضراء)
    { id = 'kidnap_citizen',   label = (Config.Language == 'ar') and 'خطف مواطن'           or 'Kidnapping Citizen',   icon = 'person',  requiredPolice = 1 },
    { id = 'house_robbery',    label = (Config.Language == 'ar') and 'سرقة منزل'           or 'House Robbery',        icon = 'house',   requiredPolice = 2 },
    { id = 'jewellery',        label = (Config.Language == 'ar') and 'سرقة مجوهرات'        or 'Jewellery',            icon = 'diamond', requiredPolice = 4 },
    { id = 'art_robbery',      label = (Config.Language == 'ar') and 'سرقة معرض الفنون'    or 'Artgallery Robbery',   icon = 'star',    requiredPolice = 4 },
    { id = 'store_robbery',    label = (Config.Language == 'ar') and 'سرقة بقالة'          or 'Store Robbery',        icon = 'store',   requiredPolice = 3 },
    { id = 'kidnap_officer',   label = (Config.Language == 'ar') and 'خطف شرطي'            or 'Kidnapping Officer',   icon = 'person',  requiredPolice = 6 },
    { id = 'fleeca_bank',      label = (Config.Language == 'ar') and 'بنك فليكا'           or 'Fleeca Bank',          icon = 'bank',    requiredPolice = 5 },
    { id = 'luxury_house',     label = (Config.Language == 'ar') and 'سرقة منزل فاخر'      or 'Luxury House Robbery', icon = 'house',   requiredPolice = 3 },
    { id = 'money_storm',      label = (Config.Language == 'ar') and 'عاصفة فلوس'          or 'Money Storm',          icon = 'money',   requiredPolice = 0 },
    { id = 'pacific_bank',     label = (Config.Language == 'ar') and 'بنك باسيفيك'         or 'Pacific Bank',         icon = 'bank',    requiredPolice = 8 },
    { id = 'train_robbery',    label = (Config.Language == 'ar') and 'سرقة قطار'           or 'Train Robbery',        icon = 'truck',   requiredPolice = 5 },
}

-- ==========================================
-- COLORS
-- ==========================================

Config.Colors = {
    Accent           = '#d4054a',
    BackgroundMain   = 'rgba(12, 12, 18, 0.96)',
    BackgroundHeader = 'rgba(16, 16, 24, 0.99)',
    TextPrimary      = '#ffffff',
    TextSecondary    = '#9090aa',
    BorderColor      = 'rgba(255, 255, 255, 0.05)',
    ActiveColor      = '#2ecc71',
    InactiveColor    = '#d4054a',
    PoliceColor      = '#3b82f6',
    EmsColor         = '#ec4899',
}
