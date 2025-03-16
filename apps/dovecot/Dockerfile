FROM dovecot/dovecot:2.3-latest

USER root

RUN apt update && apt install -y \
  spamc 

COPY sieve /usr/lib/dovecot/sieve

RUN chown -R vmail:vmail /usr/lib/dovecot/sieve && \
  chmod +x /usr/lib/dovecot/sieve/sa-learn.sh
  

USER vmail
