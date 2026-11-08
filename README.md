# Авто-сборщик [LiBwrt](https://github.com/LiBwrt/LibWrt) (форк ImmortalWrt с патчами для IPQ60XX и IPQ807X)

## Информация по поддерживаемым устройствам

- Поддержка [GL-inet AXT-1800](https://www.gl-inet.com/products/gl-axt1800/)

  > Проверено на глобальной версии, **на китайской версии делайте на свой страх
  > и риск**

  **Доступ по ssh и к панели**

  - IP: `192.168.8.1`
  - Порт: `22` (для ssh можно не указывать)
  - Пароль: нету, **как загрузитесь установите его сами**

    > Внимание: Пароля на частоты 2.4 и 5 герц нету, чтобы к вам не подключились
    > незнакомые люди рекомендуется либо:
    >
    > 1. Сразу поставить пароль в `Network` - `Wireless` - `Edit` (оба radio0 и
    >    radio1) и в `Interface Configuration` - `Wireless Securuty` выбираем
    >    в `Encryption` тип `WPA2-PSK` (или `WPA2-PSK/WPA3-SAE Mixed Mode`)
    >    и в `Key` указываем ваш пароль
    >
    > 2. На время отключить данные частоты, а когда они вам понадобятся включаем
    >    их

  **Прошивка**

  - Прошивка со стоковой прошивки Gl-inet происходит через загрузчик uboot с
    указанием файла `libwrt-qualcommax-ipq60xx-glinet_gl-axt1800-squashfs-factory.bin`

  - Если же вы на прошивке от OpenWrt/Kwrt и т.д, тогда прошивка происходит через
    меню LuCi с указанием файла `squashfs-sysupgrade.bin`

    Переходим в `System` - `Backup / Flash Firmware`, в `Flash new firmware image`
    жмём `Flash image...` выбираем `libwrt-qualcommax-ipq60xx-glinet_gl-axt1800-squashfs-sysupgrade.bin`

    > [!WARNING]
    > Убираем галочку `Keep settings and retain the current configuration`, т.к
    > устройство должно загрузится начисто, без ваших конфигураций.

    После прошиваем нажав `Continue`, подключаемся к панели только тогда когда
    индикатор на роутере будет гореть статично синим цветом

## Преимущества

- Автоматический зафиксированный vermagic для использования официального kmod
  репозитория ImmortalWrt
- Встроенные пакеты для ускорения интернета 🚀
- Настроенный из коробки FullCone NAT, ZRam
- Дополнительный набор пакетов (современная тема, файловый менеджер, менеджер дисков)
- Настроенный https с самоподписанным сертификатом (openssl)
- Встроенный [скрипт для расширения встроенной памяти роутера](https://github.com/anzix/LWrtBuilder/blob/main/files/usr/share/extpart.sh)

## Если вас не устраивают мои настройки?

Тогда [форкайте](https://github.com/anzix/LWrtBuilder/fork) и изменяйте под ваши
нужды

- defconfig (модули ядра, наличия каких-то оф. пакетов, feed репозитории и т.д):
  Для каждого устройства собственный `.config`, как например для [axt1800.config](https://github.com/anzix/LWrtBuilder/tree/main/config)
- Настройки при первом запуске: [zzz-default-settings](https://github.com/anzix/LWrtBuilder/blob/main/default-settings-anzix/files/zzz-default-settings)
- Кастомные пакеты: [git-clone.sh](https://github.com/anzix/LWrtBuilder/blob/main/sh/git-clone.sh)
- Специфичные настройки (фиксирование хеша vermagic, применение собственных
  патчей и т.д): [specific-setup.sh](https://github.com/anzix/LWrtBuilder/blob/main/sh/specific-setup.sh)

До начала сборки прошивки необходимо в вашем форк репозитории **зайти в
Settings - Actions, General** и в **`Workflow permissions`** поменять с **`Read
repository contents and packages permissions`** на **`Read and write permissions`**
и нажать **`Save`**

Это исправляет ошибку на этапе **`Generate unified publishing tags and content.`**

```txt
⚠️ GitHub release failed with status: 403
{"message":"Resource not accessible by integration","documentation_url":"https://docs.github.com/rest/releases/releases#create-a-release","status":"403"}
Skip retry — your GitHub token/PAT does not have the required permission to create a release
⚠️ Unexpected error fetching GitHub release for tag refs/heads/main: HttpError: Resource not accessible by integration - https://docs.github.com/rest/releases/releases#create-a-release
Error: Resource not accessible by integration - https://docs.github.com/rest/releases/releases#create-a-release
```

## Время сборки

В первый раз прошивка собирается где-то за 2 часа (может чуть больше). После успешной
сборки **и создания кеша** при повторной сборки - 1 час (иногда чуть дольше, +15-40
минут). Если повезёт то вообще за 40~50 минут.

## Проблемы и способы их решения

1. Текущие зеркала выдают ошибку `Bad gateway 502`

   Решение: Временно перейти на другое зеркало, например сами авторы ImmortalWrt
   в [тг канале](https://t.me/ctcgfw_project_openwrt/55) советуют использовать
   из [help.mirrorz.org](https://help.mirrorz.org/immortalwrt/)

   Команда по смене зеркала

   ```sh
   # Создастся резервная копия текущего файла distfeeds.list с репозиториями из downloads.immortalwrt.org
   sed -e 's,https://downloads.immortalwrt.org,https://mirror.nju.edu.cn/immortalwrt,g' \
       -e 's,https://mirrors.vsean.net/openwrt,https://mirror.nju.edu.cn/immortalwrt,g' \
       -i.bak /etc/apk/repositories.d/distfeeds.list
   ```

   После чего обновление индексов будет происходить нормально

   ```sh
   opkg update
   ```

   Как только починят основное зеркало возвращаем обратно

   ```sh
   # Создастся резервная копия текущего файла distfeeds.list с репозиториями из mirror.nju.edu.cn
   sed -i.bak "s,https://mirror.nju.edu.cn,https://downloads.immortalwrt.org,g" "/etc/apk/repositories.d/distfeeds.list"
   ```

2. При обновлении индексов пакета возникает множество ошибок связанных с
   `wgetSSL verify error: certificate is not yet valid`

   Это происходит из-за того, что при первом включении системное время указано
   неверно

   Переходим в `System` - `General Settings` и в `Local Time` жмём `Sync with browser`,
   после чего обновление индексов пакетов будет происходить нормально

3. Беспроводная сеть Wifi (5Ghz) постоянно разрывает соединение с подключённым
   устройством

   При проверке командой `logread | grep hostapd | tail -n 100` обнаружил в
   когда произёл обрыв соединения

   ```txt
   Sat Oct 24 11:20:41 2026 daemon.info hostapd: phy0-ap0: STA xx:xx:xx:xx:xx:67 IEEE 802.11: disconnected due to excessive missing ACKs
   Sat Oct 24 11:20:41 2026 daemon.notice hostapd: phy0-ap0: AP-STA-DISCONNECTED xx:xx:xx:xx:xx:67
   Sat Oct 24 11:20:43 2026 daemon.info hostapd: phy0-ap0: STA xx:xx:xx:xx:xx:67 IEEE 802.11: authenticated
   Sat Oct 24 11:20:43 2026 daemon.info hostapd: phy0-ap0: STA xx:xx:xx:xx:xx:67 IEEE 802.11: associated (aid 2)
   Sat Oct 24 11:20:43 2026 daemon.notice hostapd: phy0-ap0: AP-STA-CONNECTED xx:xx:xx:xx:xx:67 auth_alg=open
   Sat Oct 24 11:20:43 2026 daemon.info hostapd: phy0-ap0: STA xx:xx:xx:xx:xx:67 RADIUS: starting accounting session A4ED767DCB6A0D74
   Sat Oct 24 11:20:43 2026 daemon.info hostapd: phy0-ap0: STA xx:xx:xx:xx:xx:67 WPA: pairwise key handshake completed (RSN)
   Sat Oct 24 11:20:43 2026 daemon.notice hostapd: phy0-ap0: EAPOL-4WAY-HS-COMPLETED xx:xx:xx:xx:xx:67
   ```

   Ошибка `disconnected due to excessive missing ACKs`

   Возможные решения проблемы

   - В Luci - Сеть - Беспроводная сеть - Редактируем 5ghz точку - ниже в `Настройка
     сети` жмём `Расширенные настройки`, в самом низу убрать галочку `Не ассоциировать
     при низком подтверждении`


## TODO

- [ ] Встроить пакет [sing-box-extended](https://github.com/shtorm-7/sing-box-extended)
- [ ] Встроить пакет [zapret2-openwrt](https://github.com/1andrevich/zapret2-openwrt)

## Благодарность

- [qlxi/GL_AXT1800](https://github.com/qlxi/GL_AXT1800)
- [m0eak/Openwrt_Builder](https://github.com/m0eak/Openwrt_Builder)
- [P3TERX/Actions-OpenWrt](https://github.com/P3TERX/Actions-OpenWrt)
- [wukongdaily/AutoBuildImmortalWrt](https://github.com/wukongdaily/AutoBuildImmortalWrt)

## Лицензия

[MIT](https://github.com/anzix/LWrtBuilder/blob/main/LICENSE)
