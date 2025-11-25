# 🚀 Deployment Guide

Simple guide for deploying Suilings backend to EC2.

---

## ⚡ Quick Deploy (One Command)

When you update backend code:

```bash
./deploy.sh
```

This will:
1. Build Docker image for EC2 (AMD64)
2. Push to Docker Hub
3. Clean EC2 cache
4. Deploy to EC2
5. Verify deployment

**Time**: 5-10 minutes

---

## 📋 Configuration

Your EC2 details are in `deploy.sh`:
- **IP**: 3.213.0.115
- **User**: ubuntu
- **Key**: MyEC2KeyPair.pem

---

## ✅ Current Setup (Working)

- **Sui CLI**: testnet v1.61.1
- **Move Framework**: mainnet
- **Docker Platform**: linux/amd64 (EC2)
- **Service Port**: 3006

---

## 🆘 Troubleshooting

### "Docker login required"
```bash
docker login
```

### "No space left on device"
```bash
# Clean Docker locally
docker system prune -a -f --volumes

# Or on EC2
ssh -i MyEC2KeyPair.pem ubuntu@3.213.0.115 "docker system prune -a -f"
```

### "SSH connection failed"
Check EC2 Security Group allows SSH (port 22) from your IP.

---

## 🎯 Complete Workflow

```bash
# 1. Make your changes
git add .
git commit -m "your message"

# 2. Deploy to EC2
./deploy.sh

# 3. Verify
curl http://3.213.0.115:3006/health

# 4. Push code
git push origin main
```

---

## 🧹 Maintenance Commands (If Needed)

### Clean Docker (Free Space)
```bash
docker system prune -a -f --volumes
```

### Clean Move Build Cache
```bash
rm -rf ~/.move ~/.sui/move
rm -rf runner-crate/build runner-crate/.move
rm -rf suilings-web/compilation-service/runner-crate/build
cd runner-crate && sui move build
```

---

**Service URL**: http://3.213.0.115:3006  
**Health Check**: http://3.213.0.115:3006/health

