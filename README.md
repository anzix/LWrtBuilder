# Авто-сборщик LiBwrt (форк ImmortalWrt с патчами для IPQ60XX и IPQ807X)

## Usage

- Поддержка GL-inet AXT-1800

  **Доступ по ssh и к панели**

  - IP: `192.168.8.1`
  - ПОРТ: `22` (для ssh можно не указывать)

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

## TODO

- [x] ~~Исправить workflow связанный с медленной сборкой~~. В среднем прошивка
  собирается за 1 час (иногда чуть дольше, +15-30 минут)

- [ ] Нужно как-то решить проблему с отсутствием cron

  Чтобы решить проблему

  ```txt
  grep: /etc/crontabs/root: No such file or directory
  ```

- [ ] Почему-то не добавились пакеты русификации `luci-i18n-*-ru`

## Credits

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
