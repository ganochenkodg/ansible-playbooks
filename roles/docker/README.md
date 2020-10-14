# Описание

Подключение репозитория докера и установка docker-ce и docker-compose.


# Вспомогательные утилиты
[attach-docker](files/attach-docker/attach-docker) - альтернатива `docker exec -it $cont_name bash`
[clean-docker-images](files/clean-docker-images) - скрипт очистки образов, может выполняться по крону с `-e clean_cron=true`

# Варианты использования

С переменной `use_registry=true` будет использовать локальный registry по адресу controller:5000.
```
ansible-playbook -i ./inventory/hosts -u root -e target_role=docker anyrole.yml 
```
