FROM node:18-bullseye-slim
LABEL org.opencontainers.image.source https://github.com/mysticrenji/aws-exploration
RUN apt update && apt install -y curl jq wget unzip ca-certificates gnupg lsb-release apt-transport-https python3 python3-pip

# Install Azure CLI
#COPY azure-cupi.pub /root/.ssh/azure-cupi.pub
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash
RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null
RUN AZ_REPO=$(lsb_release -cs) && echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | tee /etc/apt/sources.list.d/azure-cli.list
# RUN wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | tee /usr/share/keyrings/trivy.gpg > /dev/null \
#     && echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" |  tee -a /etc/apt/sources.list.d/trivy.list
# RUN  curl -L "$(curl -s https://api.github.com/repos/tenable/terrascan/releases/latest | grep -o -E "https://.+?_Linux_x86_64.tar.gz")" > terrascan.tar.gz && tar -xf terrascan.tar.gz terrascan && rm terrascan.tar.gz &&  install terrascan /usr/local/bin && rm terrascan

RUN apt update && apt install -y azure-cli jq
RUN pip install --upgrade pip && \
    pip install --upgrade awscli checkov


# Install Terraform
ARG TERRAFORM_VERSION="0.15.0"
RUN cd /tmp && \
    wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/bin && \
    rm -rf /tmp/* && \
    rm -rf /var/cache/apk/* && \
    rm -rf /var/tmp/*