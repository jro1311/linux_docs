# LightDM

## Config 

- **Edit**

```bash
sudo nano /etc/lightdm/lightdm.conf
```

- Enable user list

```
[Seat:*]
greeter-hide-users=false
```

- Enable autologin

```
[Seat:*]
autologin-user=
autologin-user-timeout=0
```
