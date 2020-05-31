# zapusk-tool

Инструмент для настройки машины. 
Описание логики работы и языка см. [zapusk](https://github.com/pavelvasev/zapusk).

## Установка
```
cd some-where
git clone https://github.com/pavelvasev/zapusk-tool.git
cd zapusk-tool
cp zapusk.global.conf.example zapusk.global.conf
./download-rest-and-setup.sh
```

## Быстрое создание новой программы

1. Создайте каталог `имя.zdb`
2. Войдите в него и выполните `zapusk init`
3. Вы получите код новой запуск-программы!

## Использование
help_begin
Пусть есть некая [запуск-программа](https://github.com/pavelvasev/zapusk/tree/master/examples/1-getting-started.zdb) в каком-либо каталоге.

Запуск: `zapusk команда [параметры]`

* `команда` это имя команды, например apply, destroy и любые другие.

### Необязательные параметры:

### --zdb_dir [path]
Указание каталога запуск-программы, если он отличается от текущего.

### --state_dir [path]
Указание каталога состояния.

### --only [substr]
Выполнение только компонент, в имени которых есть substr. 
Важно: это касается имен компонент, а не имен *.ini-файлов.

### --debug
Вывод отладочной информации.

### --a "name=value"
Передача параметра запуск-программе.
Можно также: -a (для совместимости с ansible).

## Примеры
```
zapusk init
zapusk apply
zapusk apply --only block1
zapusk apply --a "target=luna"
zapusk restart --zdb_dir /where/is/my/program.zdb --state_dir /var/my-state
zapusk destroy --debug
```

## Сервисные команды
* **zapusk init** - создает простую запуск-программу в текущем каталоге.
* **zapusk help** - печатает справку.

## См. также

* [Примеры программ](https://github.com/pavelvasev/zapusk/tree/master/examples/)
* [Спецификация Zapusk](https://github.com/pavelvasev/zapusk/blob/master/spec-1.md)

help_end

## Каталог состояния
Важный параметр работы запуск-программы это каталог хранения её состояния.

* В этом каталоге zapusk-tool сохраняет информацию, какие блоки были развернуты.
* Также там создаются подкаталоги для каждого блока программы.
* Команды [os] запускаются в текущем каталоге, равном каталогу состояния блока.

state_dir необходимо указать, без этого zapusk-программы не работают.

* Вариант 1: разместите файл `zapusk.conf` в каталоге zapusk-программы следующего содержания:
```
state_dir=_state
```

* Вариант 2: запускайте zapusk-tool с аргументом [--state_dir value]. Например:
```
zapusk apply --state_dir /var/some/state
```

## Подключение библиотек Лакт

В поставке Zapusk-tool идет без библиотек. 
Есть [библиотеки ЛайнАкт](https://github.com/pavelvasev/zapusk-lact-libs), которые содержат ряд ценных кодов.

```
cd zapusk-tool/lib
git clone https://github.com/pavelvasev/zapusk-lact-libs.git
```

Примечание. Библиотеки лучше размещать прямо в папку lib, потому что так мы не мучаемся с 
указанием путей к ним, и главное что весь zapusk монтируется в вирт. машины и т.о. 
библиотеки тоже становятся доступны и там.

## Copyright
(c) 2020 Павел Васёв, ЛайнАкт
