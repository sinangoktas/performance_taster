FROM python:3.8.0-buster
WORKDIR /dns-response-time-checker
COPY requirements.txt .
COPY conf.json .
COPY dns-perf.py .

RUN pip install -r requirements.txt

CMD [ "python3", "./dns-perf.py" ]