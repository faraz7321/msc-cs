# Overview of System Setup Instructions
This guide details the steps required for configuring Wi-Fi, setting up a failsafe hotspot, establishing a secure connection for Git, and simplifying local SSH access on a Raspberry Pi.

---
## Wifi Configurations
These steps configure the Raspberry Pi to connect to a specific Wi-Fi network using NetworkManager.
1. Go to `/etc/NetworkManager/system-connections`. For example:
    ```shell
    cd /etc/NetworkManager/system-connections
    ```
2. Create a psk:
    ```shell
     wpa_passphrase 'YOUR WIFI SSID' 'VeryLongAndNicePassword'
    ```
   It will return something like:
    ```text
    network={
        ssid="YOUR WIFI SSID"
        #psk="VeryLongAndNicePassword"
        psk=YOUR-WIFI-PASSWORD-HASH
    }
    ```
3. Create a new configuration file for a new Wi-Fi `mywifi.nmconnection`. Do not add quotes to `YOUR WIFI SSID`.
    ```ini
    [connection]
    id=DESCRIPTIVE-NAME
    type=wifi
    interface-name=wlan0
    autoconnect=true
    autoconnect-priority=20
    
    [wifi]
    mode=infrastructure
    ssid=YOUR WIFI SSID
    
    [wifi-security]
    auth-alg=open
    key-mgmt=wpa-psk
    psk=YOUR-WIFI-PASSWORD-HASH
    
    [ipv4]
    method=auto
    
    [ipv6]
    addr-gen-mode=default
    method=auto
    ```
4. Fix Permissions for Security:
    ```shell
    sudo chown root:root mywifi.nmconnection
    sudo chmod 600 mywifi.nmconnection
   ```
5. Load new configurations and restart network services.
    ```shell
    sudo chown root:root mywifi.nmconnection
    sudo chmod 600 mywifi.nmconnection
    sudo nmcli con reload
    sudo systemctl restart NetworkManager
   ```
   For debugging the following commands are useful:
   - View live Logs: `sudo journalctl -u NetworkManager -f`
   - Connect Manually: `sudo nmcli connection up DESCRIPTIVE-NAME`
   - Show status of devices: `nmcli device status`
   - Show known connections: `nmcli connection show`

## Setup: Hotspot on the RaspberryPi
1. Generate a UUID:
    ```shell
    sudo apt-get install uuid-runtime
   uuidgen
    ```
2. Create a Hotspot configuration for the network manager:
    ```ini
    [connection]
    id=Hotspot
    uuid=PUT-THE-REAL-UUID-HERE
    type=wifi
    interface-name=wlan0
    autoconnect=true
    
    [wifi]
    mode=ap
    ssid=PiHotspot
    
    [wifi-security]
    key-mgmt=wpa-psk
    psk=ChangeMe1234
    
    [ipv4]
    method=shared
    address1=192.168.50.1/24
    
    [ipv6]
    method=ignore
    ```
3. Fix Permissions, Load and Start:
    ```shell
    sudo chown root:root PiHotspot.nmconnection
    sudo chmod 600 PiHotspot.nmconnection
    sudo nmcli connection load PiHotspot.nmconnection
    sudo nmcli connection up Hotspot
   ```
---
## Setup: Deploy Key
1. Generate a dedicated SSH key on the Pi:
    ```shell
    ssh-keygen -t ed25519 -C "pi-cvr-group4" -f ~/.ssh/id_ed25519_gitlab_cvr
    ```
2. Add the public key to GitLab as a Deploy Key:
   - Copy the public key: `cat ~/.ssh/id_ed25519_gitlab_cvr.pub`
   - Go to your GitLab repo $\to$ Settings $\to$ Repository $\to$ Deploy Keys
   - Paste the key and give it a title like "Shared Pi - Group X"
   - Check "Write access" only if you need to push from the Pi. Usually you only need read access for pulling. Currently, its unchecked in our repo.
3. Configure SSH to use this key:
   Create/edit `~/.ssh/config`:
    ```
       Host gitlab.gwdg.de
           HostName gitlab.gwdg.de
           User git
           IdentityFile ~/.ssh/id_ed25519_gitlab_cvr
           IdentitiesOnly yes
   ```
4. Check connection:
   ```shell
   ssh -T git@gitlab.gwdg.de
    ```
---   
## SSH configuration for easier login
On your pc, call in a git bash:
```shell
ssh-copy-id pi@100.64.0.19
```
where `100.64.0.19` is the ip address of the raspberry pi. Afterward, set (also on your pc) the ssh configuration up:
```shell
Host robot
    HostName 100.64.0.19
    User pi
    ForwardX11Trusted yes
    ForwardX11 yes
```