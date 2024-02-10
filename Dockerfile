FROM alpine:latest

RUN apk add --no-cache samba

# create the samba user
ARG SAMBA_GID=1000
ARG SAMBA_UID=1000
RUN addgroup --gid $SAMBA_GID samba
RUN adduser --uid $SAMBA_UID --ingroup samba --system samba

# prepare samba-specific directories
RUN d="/run/samba /var/cache/samba /var/lib/samba /var/log/samba"; \
    mkdir -m 0700 -p $d; chown -R samba:samba $d

# build samba share directory
RUN install -d -m 0777 -o samba -g samba /srv/share
RUN touch /srv/share/WARNING_NOT_MOUNTED

# copy over the samba configuration
COPY --chmod=644 smb.conf /etc/samba/smb.conf

EXPOSE 445/tcp

USER samba
CMD [ "smbd", "--foreground", "--no-process-group" ]
