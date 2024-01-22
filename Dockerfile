FROM python:latest as base

ARG USERNAME=pyuser
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

ENV PYTHONUSERBASE=/home/$USERNAME/.local
ENV PATH=$PYTHONUSERBASE/bin:$PATH

USER $USERNAME

WORKDIR /workspace

RUN pip install --user --upgrade pip && \
    pip install --user --upgrade setuptools


FROM base as dev

USER root

RUN apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

USER $USERNAME

CMD [ "bash" ]


FROM base as prd

USER $USERNAME

COPY . /workspace

RUN pip install --user -r requirements.txt

CMD ["streamlit", "run", "src/Home.py", "--server.port", "8501"]
