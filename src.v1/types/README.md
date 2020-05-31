# Шаги на уровне руби

Здесь шаги, написанные на руби.

Пусть мы хотим добавить свой zapusk-шаг, написанный на руби, с типом superstep, чтобы использовать
его в программах например так:
```
##################### myblock
[superstep]
gamma=14
```

Для этого следует разместить файл somename.rb в этом каталоге.
Файлы из этого каталога загружаются автоматически, см. [z1_50_perform_types.rb](../z1_50_perform_types.rb).

Пример содержания файла:

```
module MyModule15

  def perform_type_superstep( vars, nxt )
    log "vars are: #{vars.inspect}"
    log "gamma=#{vars['gamma']}"
    
    # ... код шага ...

    # вариант А - передача управления следующим шагам
    return perform_expression( nxt )
    
    # вариант Б -  останавливает управление и печатает warning если остались еще шаги
    # return stop_expression( nxt )
    
    # вариант Ц - просто сказать что все ок
    # return :done
  end

end

Zapusk.prepend MyModule15
```
* **perform_type_имятипа** - точка входа. Zapusk ищет функции по такой сигнатуре, а если не находит то вызывает perform_type_zdb, см код perform_subcomponent
* **vars** - переменные шага
* **nxt** - список следующих шагов в блоке

