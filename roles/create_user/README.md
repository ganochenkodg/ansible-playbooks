# Описание

Создает группу sudo-nopasswd, разрешающую выполнять sudo без пароля. Создает пользователя с именем из переменной `new_user_name` и добавляет ему authorized_key из файла по пути `user_pub_key`

## Использование

Пример использования:

```
ansible-playbook -i ./inventory/hosts -u root -e target_role=create_user -e new_user_name=dganochenko -e user_pub_key="~/.ssh/id_rsa.pub" anyrole.yml  -v
```
