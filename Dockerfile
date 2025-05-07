FROM quay.io/centos/centos:stream8

# Set DNS inside the container manually (temporary fix)
#RUN echo "nameserver 8.8.8.8" > /etc/resolv.conf && \
    #echo "nameserver 8.8.4.4" >> /etc/resolv.conf

# Replace CentOS repos with vault.centos.org
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*.repo && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*.repo

LABEL maintainer="Gihan gihankavin50@gmail.com" \
      description="Tuleap with Git, Wiki, and Docman plugins" \
      version="1.0"

# Enable PowerTools repository which is required for some dependencies
RUN dnf install -y dnf-plugins-core
RUN dnf config-manager --set-enabled powertools

# Install EPEL and Tuleap repositories
RUN dnf install -y epel-release

# Test connectivity before installing Tuleap repo
RUN curl -v https://rpm.tuleap.org/rpm/tuleap-release-latest.noarch.rpm || echo "Warning: Could not reach rpm.tuleap.org"

# Install Tuleap repository
RUN dnf install -y https://rpm.tuleap.org/rpm/tuleap-release-latest.noarch.rpm

# Install Tuleap with all required plugins
RUN dnf install -y tuleap-all \
    tuleap-plugin-git \
    tuleap-plugin-git-gitolite3 \
    tuleap-plugin-docman \
    tuleap-plugin-docman-watermark \
    tuleap-plugin-docman-ws \
    tuleap-plugin-docman-embedded \
    tuleap-plugin-docman-wiki \
    tuleap-plugin-agiledashboard \
    tuleap-plugin-cardwall \
    tuleap-plugin-taskboard \
    tuleap-plugin-hudson \
    tuleap-plugin-hudson-git \
    tuleap-plugin-tracker-encryption \
    tuleap-plugin-tracker-permissions \
    tuleap-plugin-tracker \
    && dnf clean all

# Install additional required dependencies
RUN dnf install -y rsyslog cronie openssh-server

# Configure environment variables
ENV DEFAULT_DOMAIN="localhost" \
    ORG_NAME="Tuleap" \
    TZ="UTC"

# Expose HTTP and HTTPS ports
EXPOSE 80 443

# Copy and set up the wrapper script
COPY docker-wrapper.sh /sbin/docker-wrapper.sh
RUN chmod 755 /sbin/docker-wrapper.sh

# Create necessary directories and set permissions
RUN mkdir -p /var/lib/tuleap/gitolite/admin
RUN chown -R codendiadm:codendiadm /var/lib/tuleap

# Set up volumes
VOLUME ["/data"]

# Set the entrypoint
CMD ["/sbin/docker-wrapper.sh"]