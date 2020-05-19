echo ""
echo "nwgat.ninja wiregard quick setup"
echo ""
echo "Endpoint (this has to be internet reachable, the script opens firewall port 5555)"
read domain

echo "Internet Forwarding Device"
read deth

# install
echo ""
echo "Installing Packages"
echo ""
sudo add-apt-repository ppa:wireguard/wireguard -y
sudo apt-get update -y
sudo apt-get install wireguard-dkms wireguard-tools ufw -y

# firewall
echo "Open Firewall"
sudo ufw allow 5555/udp

# config
echo ""
echo "Setting up wireguard"
echo ""
wg genkey | tee server_private_key | wg pubkey > server_public_key
wg genkey | tee client_private_key | wg pubkey > client_public_key

sed -i "s|domain|$domain|g" wg0-client.conf
sed -i "s|deth|$deth|g" wg0-server.conf

var1=`cat server_private_key`
var2=`cat server_public_key`
var3=`cat client_private_key`
var4=`cat client_public_key`

sed -i "s|server_private_key|$var1|g" wg0-server.conf
sed -i "s|client_public_key|$var4|g" wg0-server.conf

sed -i "s|client-private-key|$var3|g" wg0-client.conf
sed -i "s|server-public-key|$var2|g" wg0-client.conf

echo "Setting up internet routing"
echo ""
sed -i "s|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|g" -i /etc/sysctl.conf

echo "Starting wireguard service"
echo ""
cp wg0-server.conf /etc/wireguard/wg0.conf
chown -R root:root /etc/wireguard/
chmod -R og-rwx /etc/wireguard/*
systemctl enable wg-quick@wg0
wg-quick up wg0
echo ""
echo "Copy this into your client wg0.conf config"
echo ""
cat wg0-client.conf
echo ""
