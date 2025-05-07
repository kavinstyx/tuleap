FROM almalinux:9

LABEL maintainer="Gihan gihankavin50@gmail.com" \
      description="Tuleap with Git, Wiki, and Docman plugins - Dev Repo Version" \
      version="1.0"

# Set environment variables
ENV DEFAULT_DOMAIN="localhost" \
    ORG_NAME="Tuleap" \
    TZ="UTC"

# Enable required repos and install dependencies
RUN dnf install -y dnf-plugins-core && \
    dnf config-manager --set-enabled crb && \
    dnf install -y epel-release

# Add Tuleap Dev repo manually
RUN echo "[tuleap-dev]" > /etc/yum.repos.d/tuleap-dev.repo && \
    echo "name=Tuleap Dev Repository" >> /etc/yum.repos.d/tuleap-dev.repo && \
    echo "baseurl=https://ci.tuleap.net/yum/tuleap/rhel/9/dev/x86_64/" >> /etc/yum.repos.d/tuleap-dev.repo && \
    echo "enabled=1" >> /etc/yum.repos.d/tuleap-dev.repo && \
    echo "gpgcheck=0" >> /etc/yum.repos.d/tuleap-dev.repo

# Install Tuleap core and selected plugins
RUN dnf install -y \
    tuleap \
    tuleap-plugin-git \
    tuleap-gitolite3 \
    tuleap-plugin-docman \
    tuleap-plugin-cardwall \
    tuleap-plugin-agiledashboard \
    tuleap-plugin-hudson \
    tuleap-plugin-hudson-git \
    tuleap-plugin-tracker \
    tuleap-plugin-tracker-encryption \
    tuleap-theme-burningparrot \
    rsyslog cronie openssh-server && \
    dnf clean all


# Copy wrapper script and set permissions
COPY docker-wrapper.sh /sbin/docker-wrapper.sh
RUN chmod 755 /sbin/docker-wrapper.sh

# Create necessary directories and set permissions
RUN mkdir -p /var/lib/tuleap/gitolite/admin && \
    chown -R codendiadm:codendiadm /var/lib/tuleap

# Expose ports
EXPOSE 80 443

# Declare volume
VOLUME ["/data"]

# Entrypoint
CMD ["/sbin/docker-wrapper.sh"]
