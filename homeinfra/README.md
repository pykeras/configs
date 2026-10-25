# Simple Pypi and Docker-hub Cache

__This is a starter pack intended for personal use, not production. It is useful when the internet access is unavailable or to save bandwidth. __

>  _Use any LLM to customize it for your own network._

```bash
--create .env based on the sample.env
docker compose up -d
sudo cp data/certs/rootCA.pem ~
```

install `dnsmasq` and configure it so that all connection on the network can find `*.home.arpa`

```bash
sudo apt update && sudo apt install -y dnsmasq
sudo nano /etc/dnsmasq.d/infra.conf
```

```bash
# infra.conf content
address=/.home.arpa/192.168.1.21
listen-address=127.0.0.1,192.168.1.21
bind-interfaces
```

```bash
sudo systemctl restart dnsmasq.service && sudo systemctl enable dnsmasq.service
--test it
dig @127.0.0.1 reg.home.arpa
--result should show: 
reg.home.arpa.        0       IN      A       192.168.1.21
```

Now on the `modem`: `Advance > DNS > Set DNS Manually` set first option to `192.168.1.21` so that all devices connected to the modem be able to find it.

```bash
--on any client on the network
--turn off custom dns and proxies
--then run
dig reg.home.arpa

--result should show: 
reg.home.arpa.        0       IN      A       192.168.1.21
```

#### If you need to delete old cert:

````bash
sudo rm /usr/local/share/ca-certificates/infra-rootCA.crt
sudo update-ca-certificates --fresh
````

__otherwise__

__Now copy the rootCA.pem file to the client:__

```bash
scp infra.local:~/rootCA.pem ~/rootCA.pem

sudo cp ~/rootCA.pem /usr/local/share/ca-certificates/infra-rootCA.crt

sudo update-ca-certificates

sudo systemctl restart docker
```

- use the following command to test pull requests

```bash
docker login cache.home.arpa
docker login reg.home.arpa
docker pull cache.home.arpa/library/debian
```

__Firefox on debian:__ Firefox does not use the OS certificate store by default. You must import it manually or via policy. 

1. Open Firefox. 
2. Go to **Settings** -> **Privacy & Security**. 
3. Scroll down to **Certificates** and click **View Certificates**. 
4. Go to the **Authorities** tab. 
5. Click **Import**. 
6. Select your `rootCA.pem` file. 
7. **Crucial Step:** In the trust dialog, check the box **"Trust this CA to identify websites"**. 
8. Click OK. 

#### Use Python cache

_To use python cache with `uv` per project_

```toml
[tool.uv]
native-tls = true

[[tool.uv.index]]
url = "https://pypi.home.arpa/root/pypi/+simple"
default = true
```

_Add above configuration to project `pyproject.toml` file._
