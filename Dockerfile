FROM python:3

WORKDIR /usr/src/app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
add run.sh /usr/local/bin/run.sh
run chmod +x /usr/local/bin/run.sh

cmd ["/bin/bash","/usr/local/bin/run.sh"]
