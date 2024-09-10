FROM alpine:latest

ARG SAMBA_GID=1000
ARG SAMBA_UID=1000

RUN \
    # install samba
    apk add --no-cache samba \

    # create the samba user
    && addgroup --gid $SAMBA_GID samba \
    && adduser --uid $SAMBA_UID --ingroup samba --system samba \
    && (echo samba; echo samba) | smbpasswd -s -a samba \

    # prepare samba-specific directories
    && d="/run/samba /var/cache/samba /var/lib/samba /var/log/samba"; \
       mkdir -m 0700 -p $d; chown -R samba:samba $d \

    # build samba share directory
    && install -d -m 0777 -o samba -g samba /srv/share \
    && touch /srv/share/WARNING_NOT_MOUNTED

# copy over the samba configuration
COPY --chmod=644 smb.conf /etc/samba/smb.conf

EXPOSE 445/tcp

USER samba
CMD [ "smbd", "--foreground", "--no-process-group" ]
