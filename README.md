# Ansible
Проект, содержащий разные роли для подготовки машины после создания и не только.

## Использование

```
Синтаксис: ansible-playbook [options] playbook_name.yml
      -l, --limit <hosts>         фильтр хостов, на которых применяем плэйбук
      -i, --inventory <file>      использовать кастомный файл инвентори.
      -u, --user [USER]           пользователь для ansible. По умолчанию: ENV['USER']
      -v, --verbose               печатает подробности выполнения тасков
      -t, --tags <tags>           тэги, передаваемые ролям
      -e, --extra-vars key=value  переменные, передаваемые ролям
```

## Плэйбуки
На данный момент написаны следующие плэйбуки:
- [anyrole.yml](anyrole.yml) - прокатывает роль, передаваемую через target_role.
Например `ansible-playbook -i ./inventory/hosts -e target_role=atop anyrole.yml`
- [full.yml](full.yml) - прокатывает роли, готовящие новую машину к использованию.
Например `ansible-playbook -i ./inventory/hosts -l controller -u root full.yml`

## Роли
На данный момент имеются следующие роли:
- apt_common - обновляет кэш apt и ставит базовые необходимые пакеты
- atop - устанавливает atop и включает роотацию логов за 2 дня
- hosts - заполняет /etc/hosts согласно правилам в host_vars и group_vars
- docker - устанавливает docker-ce и docker-compose
- iptables - устанавливает ipset и ferm, настраивает правила файрволла
- create_user - созадние на машине пользователя с правами на sudo, docker и добавление ему публичного ключа
- disable_root - отключает доступ по паролям и пользователю root. НЕ ПРИМЕНЯТЬ до заведения хоть одного пользователя с sudo
