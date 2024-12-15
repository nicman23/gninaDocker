FROM nvidia/cuda:12.6.3-cudnn-devel-ubuntu22.04


COPY ./gnina /bin/gnina 
RUN sh -c 'yes | (apt update && apt install -y python3 python-is-python3 parallel zstd)'


COPY ./gnina-api-stage1.py /bin/gnina-api-stage1.py 
COPY ./gnina-api /bin/gnina-api 
RUN sh -c 'chmod +x /bin/gnina-api-stage1.py /bin/gnina-api /bin/gnina; mkdir /data'

# RUN sh -c 'yes | dnf install zstd'

ENTRYPOINT ["gnina-api"]

