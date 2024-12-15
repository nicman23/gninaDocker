FROM saladtechnologies/a1111:ipv6-latest

COPY gnina-api.py /bin/gnina-api.py && chmod +x /bin/gnina-api.py
COPY gnina-api /bin/gnina-api && chmod +x /bin/gnina-api
COPY gnina /bin/gnina && chmod +x gnina && mv gnina /usr/bin



ENTRYPOINT ["gnina-api"]