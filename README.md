# zapusk-tool

Инструмент для настройки машины.

## Установка
```
su
mkdir /zapusk
cd /zapusk
git clone https://github.com/pavelvasev/zapusk-tool.git
cd ./zapusk-tool
cp zapusk.global.conf.example zapusk.global.conf
./download-rest-and-setup.sh
```

## Подключение библиотек Лакт

В поставке Zapusk-tool идет без библиотек. Есть библиотеки Лакт (ЛайнАкт), которые содержат ряд осмысленных кодов.

```
git clone https://github.com/pavelvasev/zapusk-lact-libs.git /zapusk/zapusk-tool/libs/zapusk-lact-libs
```

Примечание. Библиотеки лучше размещать прямо в папку libs, потому что так мы не мучаемся с 
указанием путей к ним, и главное что весь zapusk монтируется в вирт. машины и т.о. 
библиотеки тоже становятся доступны и там.

## Использование

См examples (todo)

## Теория

(todo)

## Copyright
(c) 2020 Павел Васёв, ЛайнАкт

