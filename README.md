# qb-scoreboard
لوحة **Scoreboard** لعرض معلومات اللاعبين مع واجهة NUI، بالإضافة إلى عرض **الوظائف** و/أو **الأحداث** حسب إعدادات السيرفر.
**التطوير:** Nerd Developer — [nerd-developer.com](https://nerd-developer.com)
## المتطلبات
- **`qb-core`**
## الإعداد
- **`config/config.lua`**: إعدادات العرض، العناصر الظاهرة، وتخصيصات الواجهة.
- **اللغات**: داخل `locales/` (مثل `ar.lua` و `en.lua`).
## التشغيل
أضف المورد في `server.cfg`:
```
ensure qb-scoreboard
```
## ملفات الواجهة (NUI)
- `html/index.html`
- `html/css/style.css`
- `html/js/app.js`
---
*Developed by Nerd Developer.*
