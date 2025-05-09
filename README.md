# ShareNet

无须安装 docker 运行 Traffmonetizer 

## 系统要求

- Alpine Linux
- wget (用于下载安装脚本)

## 快速开始

在 Alpine Linux 环境下运行以下命令：

```bash
wget https://raw.githubusercontent.com/Garfyyy/sharenet/main/setup.sh && chmod +x setup.sh && ./setup.sh
```

然后根据提示输入 [your token]

## Traffmonetizer CLI 说明

本项目使用了修改版的 Traffmonetizer CLI。CLI 文件提取自官方 Docker 镜像，提取步骤如下：

1. 获取官方 Docker 镜像：
   ```bash
   docker pull packetstream/psclient:latest
   ```

2. 创建临时容器：
   ```bash
   docker create --name tm_temp packetstream/psclient:latest
   ```

4. 导出容器文件：
   ```bash
   docker export tm_temp -o tm_temp.tar
   ```
   然后从文件中找到Cli保存提取即可
   
5. 清理临时容器：
   ```bash
   docker rm tm_temp
   ```
