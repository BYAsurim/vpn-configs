@echo off
chcp 65001 > nul
cd /d "D:\vpn-checker"

echo [%date% %time%] Добавляю подписки в базу...

xray-knife subs add --url "https://raw.githubusercontent.com/igareck/vpn-configs-for-russia/refs/heads/main/BLACK_SS%%2BAll_RUS.txt"
xray-knife subs add --url "https://raw.githubusercontent.com/igareck/vpn-configs-for-russia/2e16195aecb1fe6c11a4e58d2039d14cf42c2cf7/BLACK_VLESS_RUS.txt"
xray-knife subs add --url "https://raw.githubusercontent.com/aviamastersgh/vpn-free-russia/main/ru_configs.txt"
xray-knife subs add --url "https://raw.githubusercontent.com/0xRadikal/Free-v2ray-Configs/main/top100.txt"
xray-knife subs add --url "https://raw.githubusercontent.com/aviamastersgh/vpn-free-russia/main/verified_configs.txt"
xray-knife subs add --url "https://raw.githubusercontent.com/roosterkid/openproxylist/refs/heads/main/V2RAY_RAW.txt"
xray-knife subs add --url "https://raw.githubusercontent.com/ShadowException/VPN/refs/heads/main/configs/VPN-cat-top-100"
xray-knife subs add --url "https://raw.githubusercontent.com/zieng2/wl/main/vless_universal.txt"

echo [%date% %time%] Скачиваю все конфиги (файл configs.txt будет перезаписан)...

xray-knife subs fetch --all

echo [%date% %time%] Тестирую ВСЕ конфиги и сортирую по задержке...

xray-knife http -f configs.txt -t 50 --sort -o _sorted_temp.txt --prescan

echo [%date% %time%] Оставляю только 100 лучших...

powershell -Command "Get-Content '_sorted_temp.txt' | Where-Object { $_.Trim() -ne '' } | Select-Object -First 100 | Set-Content 'best_100.txt'"

del _sorted_temp.txt

echo [%date% %time%] Готово! Лучшие 100 конфигов сохранены в best_100.txt

git add best_100.txt
git commit -m "Автообновление: %date% %time%"

echo [%date% %time%] Отправляю на GitHub...

git push origin main

if %errorlevel% equ 0 (
    echo ✅ Push на GitHub прошёл успешно!
) else (
    echo ❌ ОШИБКА Push! Проверьте подключение к интернету и права доступа.
)

pause