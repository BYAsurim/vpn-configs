@echo off
chcp 65001 > nul
cd /d "D:\vpn-checker"

echo.
echo ========================================
echo   ВЫБЕРИТЕ РЕЖИМ РАБОТЫ
echo ========================================
echo   1 - Только WiFi   (best_100.txt)
echo   2 - Только мобильный (best_100_mobile.txt)
echo   3 - Оба: WiFi -^> пауза -^> мобильный
echo ========================================
set /p MODE="Введите 1, 2 или 3: "

if "%MODE%"=="1" goto wifi_only
if "%MODE%"=="2" goto mobile_only
if "%MODE%"=="3" goto both
echo Неверный ввод. Выход.
pause
exit /b

REM ================== WiFi ==================
:wifi_only
call :fetch
call :test_configs wifi
call :push_files
goto end

REM ================== Мобильный ==================
:mobile_only
call :fetch
call :test_configs mobile
call :push_files
goto end

REM ================== Оба подряд ==================
:both
call :fetch
call :test_configs wifi

echo.
echo ========================================
echo   ПЕРЕКЛЮЧИТЕСЬ НА МОБИЛЬНЫЙ ИНТЕРНЕТ
echo   Раздайте интернет с телефона на комп.
echo   Убедитесь, что WiFi отключён.
echo   Затем нажмите любую клавишу...
echo ========================================
pause

call :test_configs mobile
call :push_files
goto end

REM ================== Подпрограмма: сбор конфигов ==================
:fetch
echo [%date% %time%] Добавляю подписки в базу...
xray-knife subs add --url "https://raw.githubusercontent.com/igareck/vpn-configs-for-russia/refs/heads/main/BLACK_SS%%2BAll_RUS.txt"
xray-knife subs add --url "https://raw.githubusercontent.com/igareck/vpn-configs-for-russia/2e16195aecb1fe6c11a4e58d2039d14cf42c2cf7/BLACK_VLESS_RUS.txt"
xray-knife subs add --url "https://raw.githubusercontent.com/aviamastersgh/vpn-free-russia/main/ru_configs.txt"
xray-knife subs add --url "https://raw.githubusercontent.com/0xRadikal/Free-v2ray-Configs/main/top100.txt"
xray-knife subs add --url "https://raw.githubusercontent.com/aviamastersgh/vpn-free-russia/main/verified_configs.txt"
xray-knife subs add --url "https://raw.githubusercontent.com/roosterkid/openproxylist/refs/heads/main/V2RAY_RAW.txt"
xray-knife subs add --url "https://raw.githubusercontent.com/ShadowException/VPN/refs/heads/main/configs/VPN-cat-top-100"
xray-knife subs add --url "https://raw.githubusercontent.com/zieng2/wl/main/vless_universal.txt"
xray-knife subs add --url "https://raw.githubusercontent.com/igareck/vpn-configs-for-russia/refs/heads/main/WHITE-CIDR-RU-all.txt"
xray-knife subs add --url "https://raw.githubusercontent.com/igareck/vpn-configs-for-russia/refs/heads/main/Vless-Reality-White-Lists-Rus-Mobile.txt"
xray-knife subs add --url "https://raw.githubusercontent.com/igareck/vpn-configs-for-russia/refs/heads/main/BLACK_VLESS_RUS_mobile.txt"
xray-knife subs add --url "https://raw.githubusercontent.com/patterniha/Free-Configs/main/configs.txt"
xray-knife subs add --url "https://raw.githubusercontent.com/itsyebekhe/PSG/main/subscriptions/xray/mix"
xray-knife subs add --url "https://raw.githubusercontent.com/patterniha/Free-Configs/main/configs.txt"
xray-knife subs add --url "https://raw.githubusercontent.com/barry-far/V2ray-Config/refs/heads/main/Sub1.txt"


echo [%date% %time%] Скачиваю все конфиги...
xray-knife subs fetch --all
exit /b

REM ================== Подпрограмма: тестирование ==================
:test_configs
set "MODE_ARG=%~1"

echo.
echo [%date% %time%] Тестирую конфиги (режим: %MODE_ARG%)...
xray-knife http -f configs.txt -t 50 --sort -o _sorted_temp.txt --prescan

if not exist _sorted_temp.txt (
    echo ОШИБКА: _sorted_temp.txt не создан. Тестирование не удалось.
    exit /b 1
)

echo [%date% %time%] Оставляю только 100 лучших...

if "%MODE_ARG%"=="wifi" (
    powershell -Command "Get-Content '_sorted_temp.txt' | Where-Object { $_.Trim() -ne '' } | Select-Object -First 100 | Set-Content 'best_100.txt'"
    echo [%date% %time%] Сохранено в best_100.txt
) else (
    powershell -Command "Get-Content '_sorted_temp.txt' | Where-Object { $_.Trim() -ne '' } | Select-Object -First 100 | Set-Content 'best_100_mobile.txt'"
    echo [%date% %time%] Сохранено в best_100_mobile.txt
)

del _sorted_temp.txt
exit /b

REM ================== Подпрограмма: пуш на GitHub ==================
:push_files
echo.
echo [%date% %time%] Отправляю на GitHub...
git add best_100.txt best_100_mobile.txt 2>nul
git commit -m "Автообновление: %date% %time%" 2>nul
git push origin main
if %errorlevel% equ 0 (
    echo ✅ Push на GitHub прошёл успешно!
) else (
    echo ❌ ОШИБКА Push! Проверьте подключение.
)
exit /b

:end
echo.
echo ========================================
echo   ВСЁ ГОТОВО!
echo ========================================
pause