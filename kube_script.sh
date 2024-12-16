#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# Step 1: Load kernel modules and configure network settings
echo "Configuring network settings..."
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

echo 1 | sudo tee /proc/sys/net/bridge/bridge-nf-call-iptables
echo 1 | sudo tee /proc/sys/net/bridge/bridge-nf-call-ip6tables
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward

# Step 2: Install dependencies and set up containerd repository
echo "Installing required dependencies..."
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "Adding containerd repository..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

# Step 3: Install and configure containerd
echo "Installing containerd..."
sudo apt-get install -y containerd.io

sudo systemctl start containerd
sudo systemctl enable containerd

echo "Configuring containerd..."
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml > /dev/null

sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd

# Step 4: Add Kubernetes repository and install kubelet, kubeadm, and kubectl
echo "Adding Kubernetes repository..."
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" \
  | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update

echo "Installing Kubernetes components..."
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

echo "Kubernetes setup completed successfully."

