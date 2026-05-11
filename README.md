# Авто-сборщик LiBwrt (форк ImmortalWrt с патчами для IPQ60XX и IPQ807X)

## Информация по поддерживаемым устройствам

- Поддержка [GL-inet AXT-1800](https://www.gl-inet.com/products/gl-axt1800/)

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

## Если вас не устраивают мои настройки?

Тогда [форкайте](https://github.com/anzix/LWrtBuilder/fork) и изменяйте под ваши
нужды

- defconfig (модули ядра, наличия каких-то оф. пакетов, feed'ы, и т.д): Для каждого
  устройства собственный `.config`, как например для [axt1800.config](https://github.com/anzix/LWrtBuilder/tree/main/config)
- Настройки при первом запуске: [zzz-default-settings](https://github.com/anzix/LWrtBuilder/blob/main/default-settings/files/zzz-default-settings)
- Кастомные пакеты: [git-clone.sh](https://github.com/anzix/LWrtBuilder/blob/main/sh/git-clone.sh)
- Специфичные настройки (фиксирование хеша vermagic, применение собственных патчей и т.д): [specific-setup.sh](https://github.com/anzix/LWrtBuilder/blob/main/sh/specific-setup.sh)

## Проблемы и способы их решения

1. Текущие зеркала выдают ошибку `Bad gateway 502`

   Решение: Временно перейти на другое зеркало, например сами авторы в [тг канале](https://t.me/ctcgfw_project_openwrt/55)
   советуют использовать из [help.mirrorz.org](https://help.mirrorz.org/immortalwrt/)

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

## TODO

- [x] ~~Исправить workflow связанный с медленной сборкой~~. В среднем прошивка
  собирается за 1 час (иногда чуть дольше, +15-30 минут). Если повезёт то вообще
  за 50 минут

- [x] ~Нужно как-то решить проблему с отсутствием cron~

  Чтобы решить проблему

  ```txt
  grep: /etc/crontabs/root: No such file or directory
  ```

- [x] ~~Исправить отсутствие пакетов для русификации `luci-i18n-*-ru`~~
- [x] Проверить работу `specific-setup.sh`, и исправить создание собственного vermagic

  Чтобы можно было собрать кастомное ядро linux не конфликтующее с официальными
  kmod модулями

- [ ] Должен быть установлен я так понимаю kmod feed репозиторий в `/etc/apk/repositories.d/distfeeds.list`,
  но в моём случае он не добавился.

  ```txt
  https://downloads.immortalwrt.org/releases/25.12-SNAPSHOT/targets/qualcommax/ipq60xx/kmods/6.12.84-1-6f890802eaff7c9b13ea5a148e6d0e9d/packages.adb
  ```

  Нужно чтобы как-то автоматически указывался этот feed

## Благодарность

- [qlxi/GL_AXT1800](https://github.com/qlxi/GL_AXT1800)
- [wukongdaily/AutoBuildImmortalWrt](https://github.com/wukongdaily/AutoBuildImmortalWrt)

И другие

- [Microsoft Azure](https://azure.microsoft.com)
- [GitHub Actions](https://github.com/features/actions)
- [OpenWrt](https://github.com/openwrt/openwrt)
- [JiaY-shi/openwrt](https://github.com/JiaY-shi/openwrt.git)
- [tmate](https://github.com/tmate-io/tmate)
- [mxschmitt/action-tmate](https://github.com/mxschmitt/action-tmate)
- [csexton/debugger-action](https://github.com/csexton/debugger-action)
- [Cowtransfer](https://cowtransfer.com)
- [WeTransfer](https://wetransfer.com/)
- [Mikubill/transfer](https://github.com/Mikubill/transfer)
- [softprops/action-gh-release](https://github.com/softprops/action-gh-release)
- [ActionsRML/delete-workflow-runs](https://github.com/ActionsRML/delete-workflow-runs)
- [dev-drprasad/delete-older-releases](https://github.com/dev-drprasad/delete-older-releases)
- [peter-evans/repository-dispatch](https://github.com/peter-evans/repository-dispatch)

## License

[MIT](https://github.com/P3TERX/Actions-OpenWrt/blob/main/LICENSE) © [**P3TERX**](https://p3terx.com)
