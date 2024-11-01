FROM hdlc/sim:scipy
RUN apt update
RUN apt install -y vim zsh 
COPY requirements.txt /opt/requirements.txt
RUN python3 -m pip install -r /opt/requirements.txt

ENV TERM=xterm-256color
USER containeruser
COPY ext /opt/ext
COPY pyuvm_tests /opt/pyuvm_tests


